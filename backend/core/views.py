import random
import os
import json
import requests
from datetime import date

from django.shortcuts import render
from django.db.models import F
from django.http import JsonResponse

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework import status
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.tokens import RefreshToken

from dotenv import load_dotenv, find_dotenv
import spotipy
from spotipy.oauth2 import SpotifyOAuth

from mcp.client.sse import sse_client
from mcp.client.session import ClientSession

load_dotenv(find_dotenv())

from .models import (
    UserProfile, Song, UserWord, UserSong, UserActivity, DaysActive, Playlist,
    PlaylistSong, Word, Language, Genre, GenreSelection,
)
from .serializers import (
    SongSerializer, UserProfileSerializer, UserWordSerializer, UserSongSerializer,
    UserActivitySerializer, DaysActiveSerializer, PlaylistSerializer, PlaylistSongSerializer,
    PlaylistCollectionSerializer, SuggestedPlaylistsSerializer, WordCardSerializer,
    UserRegistrationSerializer
)
from .views_helpers import (
    updateUserActivity, updateUserPlaylistNumSongListens, getLyricAndMissingWord,
    getSongDistractorWords, getTwoRandomSongLines, getPracticeExerciseSong,
    search_spotify_track
)

# ==========================================
# AUTHENTICATION VIEWS
# ==========================================

class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        data = super().validate(attrs)
        data['user_id'] = self.user.id
        return data

class CustomLoginView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer

class RegisterView(APIView):
    def post(self, request):
        serializer = UserRegistrationSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            UserProfile.objects.create(user=user)
            refresh = RefreshToken.for_user(user)
            return Response({
                'refresh': str(refresh),
                'access': str(refresh.access_token),
                'user_id': user.id
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# ==========================================
# PROFILE & HOME VIEWS
# ==========================================

class UpdateProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request):
        user_profile, created = UserProfile.objects.get_or_create(user=request.user)
        data = request.data

        if 'proficiency_level' in data:
            user_profile.proficiency_level = data['proficiency_level']
        
        if 'target_language' in data:
            lang_obj, _ = Language.objects.get_or_create(language_name=data['target_language'])
            user_profile.target_language = lang_obj
            
        user_profile.save()

        if 'genres' in data:
            GenreSelection.objects.filter(user_profile=user_profile).delete()
            for genre_name in data['genres']:
                # Fallback to name=genre_name as defined in models
                genre_obj, _ = Genre.objects.get_or_create(genre_name=genre_name)
                GenreSelection.objects.create(user_profile=user_profile, genre=genre_obj)

        return Response({"message": "Profile updated successfully"}, status=status.HTTP_200_OK)

class HomeScreenView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        profile, created = UserProfile.objects.get_or_create(user=request.user)
        user_profile_info = UserProfileSerializer(profile).data

        # user_progress
        num_words_learned = UserWord.objects.filter(user_profile=profile).count()
        num_songs_completed = UserSong.objects.filter(user_profile=profile).count()
        
        try:
            activity = UserActivity.objects.get(user_profile=profile)
            current_streak = activity.current_streak
        except UserActivity.DoesNotExist:
            current_streak = 0

        user_progress = {
            "num_words_learned": num_words_learned,
            "num_songs_completed": num_songs_completed,
            "current_streak": current_streak
        }
   
        # suggested_playlists
        user_playlists = list(Playlist.objects.filter(user_profile=profile).order_by('-last_date_played', '-created_date'))
        
        def getSuggestedPlaylists(user_playlists: list[Playlist]) -> dict[str, list[Playlist]]:
            suggested_playlists = {"recently_played": [], "new_playlist": []}
            
            i = 0
            while i < len(user_playlists) and user_playlists[i].last_date_played == None:
                if len(suggested_playlists["new_playlist"]) == 0:
                    suggested_playlists["new_playlist"].append(user_playlists[i])
                i += 1
            
            while i < len(user_playlists) and len(suggested_playlists["recently_played"]) < 3:
                suggested_playlists["recently_played"].append(user_playlists[i])
                i += 1
                
            if len(suggested_playlists["new_playlist"]) > 0 and len(suggested_playlists["recently_played"]) >= 3:
                suggested_playlists["recently_played"].pop()
                
            return suggested_playlists

        suggested = getSuggestedPlaylists(user_playlists=user_playlists)
        
        return Response({
            "user_info": user_profile_info,
            "user_progress": user_progress,
            "suggested_playlists": {
                "recently_played": SuggestedPlaylistsSerializer(suggested["recently_played"], many=True).data,
                "new_playlist": SuggestedPlaylistsSerializer(suggested["new_playlist"], many=True).data
            }
        })

# ==========================================
# DASHBOARD DATA VIEWS (JWT GHOST-PROOFED)
# ==========================================

class WordsLearnedView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request):
        profile = request.user.userprofile
        user_words = UserWord.objects.filter(user_profile=profile).select_related('word')
        return Response({"user_word_data": UserWordSerializer(user_words, many=True).data})

class SongsListenedView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request):
        profile = request.user.userprofile
        user_songs = UserSong.objects.filter(user_profile=profile).select_related('song')
        return Response({"user_song_data": UserSongSerializer(user_songs, many=True).data})

class UserActivityView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request):
        profile = request.user.userprofile
        
        try:
            user_activity = UserActivity.objects.get(user_profile=profile)
            user_activity_data = UserActivitySerializer(user_activity).data
        except UserActivity.DoesNotExist:
            user_activity_data = None

        days_active = DaysActive.objects.filter(user_profile=profile).order_by('-date')
        days_active_data = DaysActiveSerializer(days_active, many=True).data

        return Response({
            "streak_info": user_activity_data,
            "days_active": days_active_data
        })

class PlaylistCollectionView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request):
        profile = request.user.userprofile

        def getPlaylistCollections(user_playlists: list[Playlist]) -> dict[str, list[Playlist]]:
            playlist_collections = {
                "recently_played": [],
                "new_playlists": [], 
                "its_been_a_while": [] 
            }
            i = 0
            while i < len(user_playlists) and user_playlists[i].last_date_played == None:
                if len(playlist_collections["new_playlists"]) < 3:
                    playlist_collections["new_playlists"].append(user_playlists[i])
                i += 1
                
            todays_date = date.today()
            while i < len(user_playlists):
                if (todays_date - user_playlists[i].last_date_played).days <= 30 and len(playlist_collections["recently_played"]) < 5:
                    playlist_collections["recently_played"].append(user_playlists[i])
                elif (todays_date - user_playlists[i].last_date_played).days > 30:
                    playlist_collections["its_been_a_while"].append(user_playlists[i])
                i += 1
            return playlist_collections

        sql_query = """SELECT p.id, p.playlist_name, p.genre_id, p.proficiency_level, p.last_date_played 
                       FROM core_playlist AS p 
                       WHERE p.user_profile_id = %s 
                       GROUP BY p.id, p.playlist_name, p.genre_id, p.proficiency_level 
                       ORDER BY p.last_date_played DESC"""
                       
        user_playlists = list(Playlist.objects.raw(sql_query, [profile.id]))
        collections = getPlaylistCollections(user_playlists=user_playlists)

        return Response({"playlist_collections": {
            "recently_played": PlaylistCollectionSerializer(collections["recently_played"], many=True).data,
            "new_playlists": PlaylistCollectionSerializer(collections["new_playlists"], many=True).data,
            "its_been_a_while": PlaylistCollectionSerializer(collections["its_been_a_while"], many=True).data
        }})

class SinglePlaylistView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request):
        # We still need the playlist_id from the query param to know WHICH playlist to open
        playlist_id = request.query_params.get('playlist_id')
        if not playlist_id:
            return Response(status=status.HTTP_400_BAD_REQUEST)
            
        try:
            # Added a security check to make sure they own this playlist
            playlist = Playlist.objects.get(pk=playlist_id, user_profile=request.user.userprofile)
        except Playlist.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
        
        playlist_songs = PlaylistSong.objects.filter(playlist=playlist).select_related('song')

        return Response({
            "playlist_info": PlaylistSerializer(playlist).data,
            "playlist_songs": PlaylistSongSerializer(playlist_songs, many=True).data
        })

# ==========================================
# WEEKLY DROP & PLAYLIST GENERATORS
# ==========================================

class GenerateWeeklyDropView(APIView):
    permission_classes = [IsAuthenticated]
    def post(self, request):
        user = request.user.userprofile

        try:
            client_id = os.getenv('SPOTIFY_CLIENT_ID')
            client_secret = os.getenv('SPOTIFY_CLIENT_SECRET')
            redirect_uri = os.getenv('SPOTIPY_REDIRECT_URI')
            scope = "playlist-modify-public playlist-modify-private playlist-read-private user-read-email"
            
            auth_manager = SpotifyOAuth(
                client_id=client_id,
                client_secret=client_secret,
                redirect_uri=redirect_uri,
                scope=scope,
                cache_path="spotify_token.txt"
            )
            sp = spotipy.Spotify(auth_manager=auth_manager)
            access_token = auth_manager.get_cached_token()['access_token']
            
            url_create = "http://api.spotify.com/v1/me/playlists" # Fixed URL
            headers = {
                "Authorization": f"Bearer {access_token}",
                "Content-Type": "application/json"
            }
            data_create = {
                "name": "SongLingo Weekly Drop",
                "public": False,
                "description": "Your curated language learning tracks for the week."
            }
            
            response_create = requests.post(url_create, headers=headers, json=data_create)
            if response_create.status_code not in [200, 201]:
                return Response({"error": f"spotify failed: {response_create.text}"}, status=status.HTTP_502_BAD_GATEWAY)
                
            playlist_data = response_create.json()
            playlist_id = playlist_data['id']

            db_playlist = Playlist.objects.create(
                user_profile=user,
                playlist_name=playlist_data['name'],
                language=user.target_language
            )

            weekly_songs = [
                {"title": "Despacito", "artist": "Luis Fonsi"},
                {"title": "Bidi Bidi Bom Bom", "artist": "Selena"},
                {"title": "Danza Kuduro", "artist": "Don Omar"},
                {"title": "Vivir Mi Vida", "artist": "Marc Anthony"},
                {"title": "Con Altura", "artist": "ROSALÍA"}
            ]
            
            track_uris = []
            for song in weekly_songs:
                result = search_spotify_track(song["title"], song["artist"], access_token)
                if result:
                    track_uris.append(f"spotify:track:{result['spotify_id']}")
                    db_song, _ = Song.objects.get_or_create(
                        spotify_id=result['spotify_id'],
                        defaults={'title': result['title'], 'artist': result['artist']}
                    )
                    PlaylistSong.objects.create(playlist=db_playlist, song=db_song)

            if track_uris:
                sp.playlist_add_items(playlist_id, track_uris)
                
            return Response({
                "message": "weekly drop generated successfully!",
                "playlist_id": db_playlist.id,
                "spotify_url": playlist_data['external_urls']['spotify']
            }, status=status.HTTP_201_CREATED)
            
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
class RegisterView(APIView):
    # Allow anyone to hit this endpoint so they can actually sign up
    permission_classes = [AllowAny] 
    
    def post(self, request):
        serializer = UserRegistrationSerializer(data=request.data)
        
        if serializer.is_valid():
            user = serializer.save()
            refresh = RefreshToken.for_user(user)
            
            return Response({
                'refresh': str(refresh),
                'access': str(refresh.access_token),
                'user_id': user.id
            }, status=status.HTTP_201_CREATED)
            
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# Your distractor dictionary
SPANISH_DICTIONARY = {
    "novia": {"def": "girlfriend", "distractors": ["sister", "mother", "aunt", "friend"]},
    "mañana": {"def": "tomorrow", "distractors": ["today", "yesterday", "tonight", "morning"]},
    "boda": {"def": "wedding", "distractors": ["party", "funeral", "birthday", "meeting"]},
    "mucho": {"def": "a lot", "distractors": ["a little", "nothing", "everything", "some"]},
    "corazón": {"def": "heart", "distractors": ["mind", "soul", "body", "blood"]}
}

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def fetch_word_cards(request):
    profile, created = UserProfile.objects.get_or_create(user=request.user)

    user_playlists = Playlist.objects.filter(user_profile=profile)
    saved_songs = PlaylistSong.objects.filter(playlist__in=user_playlists).select_related('song')
    
    vocab_pool = set()
    for ps in saved_songs:
        try:
            song_vocab = ps.song.vocabulary_json 
            if song_vocab:
                vocab_pool.update(song_vocab)
        except AttributeError:
            pass

    valid_words = [word for word in vocab_pool if word in SPANISH_DICTIONARY]
    
    if not valid_words:
        valid_words = ["novia", "mañana", "boda"]

    random.shuffle(valid_words)
    session_words = valid_words[:10]
    
    practice_words = []
    word_distractors = []
    
    for word in session_words:
        data = SPANISH_DICTIONARY[word]
        practice_words.append({
            "word_text": word,
            "definition": data["def"]
        })
        word_distractors.append(random.sample(data["distractors"], 3))

    return Response({
        "practice_words": practice_words,
        "word_distractors": word_distractors
    })


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def generate_weekly_playlist(request):
    try:
        profile, created = UserProfile.objects.get_or_create(user=request.user)
        
        user_level = getattr(profile, 'proficiency_level', 'Beginner') 

        # Make sure we use AnalyzedSong if that is where difficulty_level lives
        matching_songs = Song.objects.filter(proficiency_level=user_level)
        if not matching_songs.exists():
            return Response({"error": f"No songs found for level {user_level}"}, status=404)

        song_pool = list(matching_songs)
        num_songs = min(len(song_pool), 5) 
        selected_songs = random.sample(song_pool, num_songs)

        playlist = Playlist.objects.create(
            user_profile=profile,
            playlist_name="Your Weekly Mix"
        )

        PlaylistSong.objects.bulk_create([
            PlaylistSong(playlist=playlist, song=song) 
            for song in selected_songs
        ])

        playlist_data = [{
            "id": entry.id,
            "title": entry.title,
            "artist": entry.artist,
            "lyrics": entry.lyrics,
            "proficiency_level": entry.difficulty_level,
            "vocabulary": getattr(entry, 'vocabulary_json', [])
        } for entry in selected_songs]

        return Response({
            "playlist_info": {
                "id": playlist.id,
                "name": playlist.playlist_name,
                "description": f"Curated for {user_level} learners."
            },
            "songs": playlist_data
        }, status=status.HTTP_201_CREATED)
    
    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
# ==========================================
# PROGRESS UPDATERS
# ==========================================

@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def updateUserWordNumPracticesCompleted(request):
    profile = request.user.userprofile
    word_id = request.query_params.get('word_id')
    if not word_id:
        return Response(status=status.HTTP_400_BAD_REQUEST)
    
    updateUserActivity(profile.id) 
    rows_updated = UserWord.objects.filter(user_profile=profile, word_id=word_id).update(
        num_practices_completed=F('num_practices_completed') + 1
    )
    return Response({"rows_updated": rows_updated}, status=status.HTTP_200_OK)

@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def updateUserSongProgress(request):
    profile = request.user.userprofile
    song_id = request.query_params.get('song_id')
    request_type = request.query_params.get('request_type')
    playlist_id = request.query_params.get('playlist_id')
    
    if not song_id or not request_type:
        return Response(status=status.HTTP_400_BAD_REQUEST)
    
    updateUserActivity(profile.id)
    user_song = UserSong.objects.filter(user_profile=profile, song_id=song_id)
    
    song_rows_updated = 0
    if request_type == "song_listen":
        song_rows_updated = user_song.update(num_listens=F('num_listens') + 1)
    elif request_type == "lyric_challenge":
        song_rows_updated = user_song.update(num_lyric_challenges_completed=F('num_lyric_challenges_completed') + 1)

    playlist_rows_updated = updateUserPlaylistNumSongListens(playlist_id) if (playlist_id and request_type == "song_listen") else 0

    return Response({
        "song_rows_updated": song_rows_updated,
        "playlist_rows_updated": playlist_rows_updated
    }, status=status.HTTP_200_OK)

# ==========================================
# EXERCISE DATA GENERATORS
# ==========================================

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def getCompleteTheLyricExercise(request):
    profile = request.user.userprofile
    practice_song = getPracticeExerciseSong(profile.id)
    lyric_and_word = getLyricAndMissingWord(practice_song)
    distractor_words = getSongDistractorWords(practice_song, lyric_and_word[1])

    return Response({
        "lyric": lyric_and_word[0],
        "missing_word": lyric_and_word[1],
        "distractor_words": distractor_words,
        "song_title": practice_song.title,
        "song_artist": practice_song.artist
    })

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def getLyricMatchExercise(request):
    profile = request.user.userprofile
    practice_song = getPracticeExerciseSong(profile.id)
    two_song_lines = getTwoRandomSongLines(practice_song)
    
    return Response({
        "line_to_display": two_song_lines[0],
        "line_to_match": two_song_lines[1],
        "song_title": practice_song.title,
        "song_artist": practice_song.artist
    })

# ==========================================
# FAST MCP PROXY
# ==========================================

@api_view(['GET'])
@permission_classes([AllowAny])
async def get_pronunciation(request, word):
    mcp_url = "http://fastmcp:8001/sse"
    try:
        async with sse_client(mcp_url) as streams:
            async with ClientSession(streams[0], streams[1]) as session:
                await session.initialize()
                result = await session.call_tool(
                    "get_audio_and_phonetics",
                    arguments={"word": word, "language_code": "es", "region_tld": "com.mx"}
                )
                tool_response = json.loads(result.content[0].text)
                
                return JsonResponse({
                    "success": True,
                    "word": tool_response["word"],
                    "phonetic": tool_response["phonetic"],
                    "audio": tool_response["audio_base64"]
                })
    except Exception as e:
        return JsonResponse({"success": False, "error": str(e)}, status=500)
