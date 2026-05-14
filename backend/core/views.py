import random
from django.shortcuts import render
from django.db.models import F
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework import status
from datetime import date
import os
import requests
from dotenv import load_dotenv, find_dotenv
import spotipy
from spotipy.oauth2 import SpotifyOAuth
from .views_helpers import search_spotify_track
from rest_framework.permissions import AllowAny
from rest_framework.decorators import permission_classes
from rest_framework.permissions import AllowAny

load_dotenv(find_dotenv())

from .models import (
  UserProfile, Song, UserWord, UserSong, UserActivity, DaysActive, Playlist,
  PlaylistSong, Word
)
from .serializers import (
    SongSerializer, UserProfileSerializer, UserWordSerializer, UserSongSerializer,
    UserActivitySerializer, DaysActiveSerializer, PlaylistSerializer, PlaylistSongSerializer,
    PlaylistCollectionSerializer, SuggestedPlaylistsSerializer, WordCardSerializer
)
from .views_helpers import (
    updateUserActivity, updateUserPlaylistNumSongListens, getLyricAndMissingWord, getSongDistractorWords,
    getTwoRandomSongLines, getPracticeExerciseSong
)

from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

class HomeScreenView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        # Identify the user strictly by their JWT token
        profile = request.user.userprofile
        
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
            suggested_playlists = {
                "recently_played": [],
                "new_playlist": []
            }
            
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
        recently_played_serialized = SuggestedPlaylistsSerializer(suggested["recently_played"], many=True).data
        new_playlist_serialized = SuggestedPlaylistsSerializer(suggested["new_playlist"], many=True).data

        return Response({
            "user_info": user_profile_info,
            "user_progress": user_progress,
            "suggested_playlists": {
                "recently_played": recently_played_serialized,
                "new_playlist": new_playlist_serialized
            }
        })
    

class WordsLearnedView(APIView):
    def get(self, request): # returns all data for the user's "Words Learned" screen
        
        user_id = request.query_params.get('user_id', None)
        if user_id == None:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        user_words = UserWord.objects.filter(user_profile=user_id).select_related('word')
        user_word_data = UserWordSerializer(user_words, many=True).data
        return Response({"user_word_data": user_word_data})


class SongsListenedView(APIView):
    def get(self, request): # returns all data for the user's "Songs Listened" screen

        user_id = request.query_params.get('user_id', None)
        if user_id == None:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        user_songs = UserSong.objects.filter(user_profile=user_id).select_related('song')
        user_song_data = UserSongSerializer(user_songs, many=True).data
        return Response({"user_song_data": user_song_data})


class UserActivityView(APIView):
    def get(self, request): # returns all data for the user's "Activity" screen (streak/calendar)

        user_id = request.query_params.get('user_id', None)
        if user_id == None:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        user_activity = UserActivity.objects.get(user_profile=user_id)
        user_activity_data = UserActivitySerializer(user_activity).data # contains streak info

        days_active = DaysActive.objects.filter(user_profile=user_id).order_by('-date')
        days_active_data = DaysActiveSerializer(days_active, many=True).data

        return Response({"streak_info": user_activity_data,
                         "days_active": days_active_data})


class PlaylistCollectionView(APIView):
    def get(self, request): # returns all data for the user's "Playlist Collection" screen

        # |-- helper function --|
        def getPlaylistCollections(user_playlists: list[Playlist]) -> dict[str, list[Playlist]]:
            playlist_collections = { # return value
                "recently_played": [], # last played date <= 30 days, order by most recent date played, LIMIT 5
                "new_playlists": [], # have never been listened to, last_date_played == None, LIMIT 3
                "its_been_a_while": [] # last_played_date > 30 days, NO LIMIT
            }
            i = 0
            # get new_playlists
            while i < len(user_playlists) and user_playlists[i].last_date_played == None:
                if len(playlist_collections["new_playlists"]) < 3:
                    playlist_collections["new_playlists"].append(user_playlists[i])
                i += 1
            # get recently_played and its_been_a_while playlists
            todays_date = date.today()
            while i < len(user_playlists):
                if (todays_date - user_playlists[i].last_date_played).days <= 30 and len(playlist_collections["recently_played"]) < 5:
                    playlist_collections["recently_played"].append(user_playlists[i])
                elif (todays_date - user_playlists[i].last_date_played).days > 30:
                    playlist_collections["its_been_a_while"].append(user_playlists[i])
                i += 1
            return playlist_collections
        # |-- end helper function --|

        user_id = request.query_params.get('user_id', None)
        if user_id == None:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        sql_query = "SELECT " \
        "               p.id, p.playlist_name, p.genre_id, p.proficiency_level, p.last_date_played " \
        "           FROM core_playlist AS p" \
        "           WHERE p.user_profile_id = %s" \
        "           GROUP BY p.id, p.playlist_name, p.genre_id, p.proficiency_level" \
        "           ORDER BY p.last_date_played DESC"
        user_playlists = list(Playlist.objects.raw(sql_query, [user_id])) # all user's playlists sorted by last_played_date descending

        playlist_collections = getPlaylistCollections(user_playlists=user_playlists)
        recently_played_serialized = PlaylistCollectionSerializer(playlist_collections["recently_played"], many=True).data
        new_playlists_serialized = PlaylistCollectionSerializer(playlist_collections["new_playlists"], many=True).data
        its_been_a_while_serialized = PlaylistCollectionSerializer(playlist_collections["its_been_a_while"], many=True).data

        return Response({"playlist_collections": {
            "recently_played": recently_played_serialized,
            "new_playlists": new_playlists_serialized,
            "its_been_a_while": its_been_a_while_serialized
        }})
    
    

class SinglePlaylistView(APIView):
    def get(self, request): # returns all data for a single "Playlist" screen

        playlist_id = request.query_params.get('playlist_id', None)
        if playlist_id == None:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        try:
            playlist = Playlist.objects.get(pk=playlist_id)
        except Playlist.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
        
        playlist_info = PlaylistSerializer(playlist).data
        playlist_songs = PlaylistSong.objects.filter(playlist=playlist_id).select_related('song')
        playlist_song_data = PlaylistSongSerializer(playlist_songs, many=True).data

        return Response({"playlist_info": playlist_info,
                         "playlist_songs": playlist_song_data})
    
    
class GenerateWeeklyDropView(APIView):
    def post(self, request):
        user_id = request.data.get('user_id')
        if not user_id:
            return Response({"error": "missing user_id"}, status=status.HTTP_400_BAD_REQUEST)

        # grab exact user who triggered this
        try:
            user = UserProfile.objects.get(pk=user_id)
        except UserProfile.DoesNotExist:
            return Response({"error": "user not found"}, status=status.HTTP_404_NOT_FOUND)

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
            
            # 1. create the playlist on spotify's actual servers
            url_create = "https://api.spotify.com/v1/me/playlists"
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

            # 2. save the empty playlist to our postgres db
            db_playlist = Playlist.objects.create(
                user_profile=user,
                playlist_name=playlist_data['name'],
                language=user.target_language #grab user language to tie to playlist creation. atp only doing spanish
            )

            # 3. the curated songs
            weekly_songs = [
                {"title": "Despacito", "artist": "Luis Fonsi"},
                {"title": "Bidi Bidi Bom Bom", "artist": "Selena"},
                {"title": "Danza Kuduro", "artist": "Don Omar"},
                {"title": "Vivir Mi Vida", "artist": "Marc Anthony"},
                {"title": "Con Altura", "artist": "ROSALÍA"}
            ]
            
            track_uris = []
            
            # 4. search spotify, save to postgres, and link to playlist
            for song in weekly_songs:
                result = search_spotify_track(song["title"], song["artist"], access_token)
                
                if result:
                    track_uris.append(f"spotify:track:{result['spotify_id']}")
                    
                    # save song to db (get_or_create prevents duplicates)
                    db_song, created = Song.objects.get_or_create(
                        spotify_id=result['spotify_id'],
                        defaults={'title': result['title'], 'artist': result['artist']}
                    )
                    
                    # link song to playlist in the join table
                    PlaylistSong.objects.create(
                        playlist=db_playlist,
                        song=db_song
                    )

            # 5. add found tracks to actual spotify playlist
            if track_uris:
                sp.playlist_add_items(playlist_id, track_uris)
                
            return Response({
                "message": "weekly drop generated successfully!",
                "playlist_id": db_playlist.id,
                "spotify_url": playlist_data['external_urls']['spotify']
            }, status=status.HTTP_201_CREATED)
            
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)



@api_view(['PUT'])
def updateUserWordNumPracticesCompleted(request): # increments (+1) UserWord.num_practices_completed for the requested user
    user_id = request.query_params.get('user_id', None)
    word_id = request.query_params.get('word_id', None)
    if user_id == None or word_id == None:
        return Response(status=status.HTTP_400_BAD_REQUEST)
    
    updateUserActivity(user_id) # from views_helpers, updates streak and days active if this happened on a new day

    user_word = UserWord.objects.filter(user_profile_id=user_id, word_id=word_id)
    rows_updated = user_word.update(num_practices_completed=F('num_practices_completed') + 1)
    
    return Response(
        {"rows_updated": rows_updated},
        status=status.HTTP_200_OK
    )

@api_view(['PUT'])
def updateUserSongProgress(request): # increments (+1) UserSong.num_listens OR UserSong.num_lyric_challenges completed based on req_type
    user_id = request.query_params.get('user_id', None)
    song_id = request.query_params.get('song_id', None)
    request_type = request.query_params.get('request_type', None)
    playlist_id = request.query_params.get('playlist_id', None)
    if user_id == None or song_id == None or request_type == None:
        return Response(status=status.HTTP_400_BAD_REQUEST)
    
    updateUserActivity(user_id) # from views_helpers, updates streak and days active if this happened on a new day

    user_song = UserSong.objects.filter(user_profile_id=user_id, song_id=song_id)
    song_rows_updated = 0
    if request_type == "song_listen":
        song_rows_updated = user_song.update(num_listens=F('num_listens') + 1)
    elif request_type == "lyric_challenge":
        song_rows_updated = user_song.update(num_lyric_challenges_completed=F('num_lyric_challenges_completed') + 1)

    # from views_helpers, updates Playlist.num_song_listens if this song came from a playlist
    playlist_rows_updated = updateUserPlaylistNumSongListens(playlist_id) if (playlist_id and request_type == "song_listen") else 0

    return Response(
        {"song_rows_updated": song_rows_updated,
         "playlist_rows_updated": playlist_rows_updated},
        status=status.HTTP_200_OK
    )



# PRACTICE EXERCISE ENDPOINTS

@api_view(['GET'])
def getWordCardExercise(request): # returns the user's 10 least practiced words and their relevant info
    user_id = request.query_params.get('user_id', None)
    if user_id == None:
        return Response(status=status.HTTP_400_BAD_REQUEST)
    sql_query = "SELECT " \
    "               w.id, w.word_text, w.translation, w.pronunciation, w.definition," \
    "           uw.num_practices_completed, uw.mastery_lvl" \
    "           FROM core_userword AS uw" \
    "           JOIN core_word AS w ON w.id = uw.word_id" \
    "           WHERE uw.user_profile_id = %s" \
    "           GROUP BY uw.num_practices_completed, uw.mastery_lvl, w.id, w.word_text, w.translation, w.pronunciation, w.definition" \
    "           ORDER BY uw.num_practices_completed" \
    "           LIMIT 10"
    
    practice_words = list(Word.objects.raw(sql_query, [user_id]))

    word_distractors = []
    most_listened_song = UserSong.objects.filter(user_profile=user_id).order_by('-num_listens').first().song
    if most_listened_song != None:
        for word in practice_words:
            distractors = getSongDistractorWords(most_listened_song, word)
            word_distractors.append(distractors)

    practice_words_serialized = WordCardSerializer(practice_words, many=True).data
    return Response(
        {"practice_words": practice_words_serialized,
         "word_distractors": word_distractors
        },
        status=status.HTTP_200_OK
    )
    

@api_view(['GET'])
def getCompleteTheLyricExercise(request):
    user_id = request.query_params.get('user_id', None)
    if user_id == None:
        return Response(status=status.HTTP_400_BAD_REQUEST)

    practice_song = getPracticeExerciseSong(user_id)
    lyric_and_word = getLyricAndMissingWord(practice_song)
    distractor_words = getSongDistractorWords(practice_song, lyric_and_word[1])

    return Response(
        {"lyric": lyric_and_word[0],
         "missing_word": lyric_and_word[1],
         "distractor_words": distractor_words,
         "song_title": practice_song.title,
         "song_artist": practice_song.artist
        }
    )


@api_view(['GET'])
def getLyricMatchExercise(request):
    user_id = request.query_params.get('user_id', None)
    if user_id == None:
        return Response(status=status.HTTP_400_BAD_REQUEST)
    
    practice_song = getPracticeExerciseSong(user_id)
    two_song_lines = getTwoRandomSongLines(practice_song)
    
    return Response(
        {"line_to_display": two_song_lines[0],
         "line_to_match": two_song_lines[1],
         "song_title": practice_song.title,
         "song_artist": practice_song.artist}
    )
from django.http import JsonResponse
from mcp.client.sse import sse_client
from mcp.client.session import ClientSession
import json

@api_view(['GET'])
@permission_classes([AllowAny])
async def get_pronunciation(request, word):
    
    mcp_url = "http://fastmcp:8001/sse"
    
    try:
        # connect to the fastmcp server
        async with sse_client(mcp_url) as streams:
            async with ClientSession(streams[0], streams[1]) as session:
                await session.initialize()
                
                # trigger the exact python function we built earlier
                result = await session.call_tool(
                    "get_audio_and_phonetics",
                    arguments={"word": word, "language_code": "es", "region_tld": "com.mx"}
                )
                
                # fastmcp returns the dictionary as a json string in the text block
                tool_response = json.loads(result.content[0].text)
                
                return JsonResponse({
                    "success": True,
                    "word": tool_response["word"],
                    "phonetic": tool_response["phonetic"],
                    "audio": tool_response["audio_base64"]
                })
                
    except Exception as e:
        return JsonResponse({"success": False, "error": str(e)}, status=500)
    
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework_simplejwt.views import TokenObtainPairView

class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        # Get the standard tokens
        data = super().validate(attrs)
        # Add the user_id for the iOS app
        data['user_id'] = self.user.id
        return data

class CustomLoginView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer

from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import UserRegistrationSerializer

class RegisterView(APIView):
    def post(self, request):
        serializer = UserRegistrationSerializer(data=request.data)
        
        if serializer.is_valid():
            user = serializer.save()
            
            # Generate JWT tokens for the newly created user
            refresh = RefreshToken.for_user(user)
            
            # Return the exact same structure as your CustomLoginView
            return Response({
                'refresh': str(refresh),
                'access': str(refresh.access_token),
                'user_id': user.id
            }, status=status.HTTP_201_CREATED)
            
        # If the username is taken or data is bad, return the specific errors
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import UserRegistrationSerializer

class RegisterView(APIView):
    def post(self, request):
        serializer = UserRegistrationSerializer(data=request.data)
        
        if serializer.is_valid():
            user = serializer.save()
            
            # Generate JWT tokens for the newly created user
            refresh = RefreshToken.for_user(user)
            
            # Return the exact same structure as your CustomLoginView
            return Response({
                'refresh': str(refresh),
                'access': str(refresh.access_token),
                'user_id': user.id
            }, status=status.HTTP_201_CREATED)
            
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

import random
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import UserProfile, Playlist, PlaylistSong

# Your distractor dictionary
SPANISH_DICTIONARY = {
    "novia": {"def": "girlfriend", "distractors": ["sister", "mother", "aunt", "friend"]},
    "mañana": {"def": "tomorrow", "distractors": ["today", "yesterday", "tonight", "morning"]},
    "boda": {"def": "wedding", "distractors": ["party", "funeral", "birthday", "meeting"]},
    "mucho": {"def": "a lot", "distractors": ["a little", "nothing", "everything", "some"]},
    "corazón": {"def": "heart", "distractors": ["mind", "soul", "body", "blood"]}
}

@api_view(['GET'])
def fetch_word_cards(request, user_id):
    try:
        profile = UserProfile.objects.get(user__id=user_id)
    except UserProfile.DoesNotExist:
        return Response({"error": "User not found"}, status=404)

    # get all playlists for this user
    user_playlists = Playlist.objects.filter(user_profile=profile)
    
    # get all songs in those playlists
    # Adjust 'song' to whatever your related name is (e.g., analyzed_song)
    saved_songs = PlaylistSong.objects.filter(playlist__in=user_playlists).select_related('song')
    
    # Aggregate all unique vocabulary words from these songs
    vocab_pool = set()
    for ps in saved_songs:
        # Assuming your song model has a JSONField called vocabulary_json
        song_vocab = ps.song.vocabulary_json 
        if song_vocab:
            vocab_pool.update(song_vocab)

    # filter the pool to only include words we have definitions for
    valid_words = [word for word in vocab_pool if word in SPANISH_DICTIONARY]
    
    # Optional: If they don't have enough words, you could fall back to a default list
    if not valid_words:
        valid_words = ["novia", "mañana", "boda"]

    # pick up to 10 random words for this session
    random.shuffle(valid_words)
    session_words = valid_words[:10]
    
    practice_words = []
    word_distractors = []
    
    # build array Jaci's frontend needs
    for word in session_words:
        data = SPANISH_DICTIONARY[word]
        
        practice_words.append({
            "word_text": word,
            "definition": data["def"]
        })
        
        # pick exactly 3 random distractors
        distractors = random.sample(data["distractors"], 3)
        word_distractors.append(distractors)

    return Response({
        "practice_words": practice_words,
        "word_distractors": word_distractors
    })

import random
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import UserProfile, AnalyzedSong, Playlist, PlaylistSong

@api_view(['POST'])
def generate_weekly_playlist(request, user_id):
    try:
        profile = UserProfile.objects.get(user__id=user_id)
        
        # 1. Determine the user's target level 
        # (Assuming you have a level field. If not, default to something)
        user_level = getattr(profile, 'proficiency_level', 'Beginner') 

        # 2. Query the database for ALL songs matching their level
        matching_songs = AnalyzedSong.objects.filter(difficulty_level=user_level)
        
        if not matching_songs.exists():
            return Response({"error": f"No songs found for level {user_level}"}, status=404)

        # 3. The Randomizer: Convert queryset to a list and pick 5 unique songs
        song_pool = list(matching_songs)
        num_songs = min(len(song_pool), 5) # Prevent errors if you have fewer than 5 songs
        selected_songs = random.sample(song_pool, num_songs)

        # 4. Create the new Playlist in the database
        playlist = Playlist.objects.create(
            user_profile=profile,
            playlist_name="Your Weekly Mix",
            # Add other fields like creation_date if your model requires them
        )

        # 5. Link the selected songs to the playlist
        # We use bulk_create for performance so it's one DB hit instead of five
        PlaylistSong.objects.bulk_create([
            PlaylistSong(playlist=playlist, song=song) 
            for song in selected_songs
        ])

        # 6. Serve the finalized data back to the frontend
        # This formats the response exactly how Austin's SinglePlaylistView expects it
        playlist_data = []
        for entry in selected_songs:
            playlist_data.append({
                "id": entry.id,
                "title": entry.title,
                "artist": entry.artist,
                "lyrics": entry.lyrics,
                "proficiency_level": entry.difficulty_level,
                "vocabulary": entry.vocabulary_json
            })

        return Response({
            "playlist_info": {
                "id": playlist.id,
                "name": playlist.playlist_name,
                "description": f"Curated for {user_level} learners."
            },
            "songs": playlist_data
        }, status=201)

    except UserProfile.DoesNotExist:
        return Response({"error": "User not found"}, status=404)
    except Exception as e:
        return Response({"error": str(e)}, status=500)