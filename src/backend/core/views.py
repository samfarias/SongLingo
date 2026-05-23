"""
Module: views
Description: Defines primary REST controller classes and function-based API endpoints
             for Django REST Framework in the SongLingo application.
"""
import random
import os
import json
import requests
from datetime import date, datetime
from collections import Counter

from django.shortcuts import render
from django.db.models import F
from django.http import JsonResponse
from django.utils import timezone

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework import status
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.tokens import RefreshToken

from dotenv import load_dotenv, find_dotenv

from gtts import gTTS
import base64
import io
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
    search_spotify_track, getEnglishWordDistractors,
    refreshSpotifyCredentials, createSpotifyPlaylist, syncPlaylistToSpotify
)

from .helpers import fetch_word_info, clean_and_format_word, get_unique_words_from_lyrics

# ==========================================
# AUTHENTICATION VIEWS
# ==========================================

class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    """
    Serializer providing customized authentication payload with user ID.
    """
    def validate(self, attrs):
        data = super().validate(attrs)
        data['user_id'] = self.user.id
        return data

class CustomLoginView(TokenObtainPairView):
    """
    API endpoint to authenticate users and issue JWT access and refresh tokens.
    """
    serializer_class = CustomTokenObtainPairSerializer

class LogoutView(APIView):
    """
    API endpoint to log out the user and unlink their Spotify account.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        from .models import SpotifyCredentials
        try:
            request.user.spotify_creds.delete()
        except SpotifyCredentials.DoesNotExist:
            pass
        return Response({"status": "logged out"}, status=status.HTTP_200_OK)

class RegisterView(APIView):
    """
    API endpoint for self-service user registration.

    Request Body:
        - username (str): Selected username.
        - password (str): User password.

    Responses:
        - 201 Created: { 'refresh': str, 'access': str, 'user_id': int }
        - 400 Bad Request: Serializer validation error dictionary.
    """
    # allow anyone to hit this endpoint so they can actually sign up
    permission_classes = [AllowAny] 
    
    def post(self, request):
        serializer = UserRegistrationSerializer(data=request.data)
        
        if serializer.is_valid():
            user = serializer.save()
            
            # Force the profile creation so the signal fires
            profile, _ = UserProfile.objects.get_or_create(user=user)

            UserActivity.objects.create(user_profile=profile)
            updateUserActivity(profile.pk)
            
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
    """
    API endpoint to update the user profile configuration (proficiency, target language, genre interests).

    Request Body (Partial/Patch):
        - proficiency_level (str): 'Beginner', 'Intermediate', or 'Advanced'.
        - target_language (str): Name of language to study.
        - genres (list[str]): List of target musical genre names.

    Side Effects:
        - Database mutation: Updates UserProfile and associated GenreSelection records.
    """
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
    """
    API endpoint supplying full home dashboard parameters for the active user.

    Purpose:
        Retrieves user information, dynamic language learning progress stats
        (words learned, songs completed, streaks), and playlist suggestion feeds.

    Outputs:
        - 200 OK: { "user_info": dict, "user_progress": dict, "suggested_playlists": dict }
    """
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
                if len(suggested_playlists["new_playlist"]) < 3 or user_playlists[i].created_date == date.today():
                    suggested_playlists["new_playlist"].append(user_playlists[i])
                i += 1
            
            while i < len(user_playlists) and len(suggested_playlists["recently_played"]) < 3:
                suggested_playlists["recently_played"].append(user_playlists[i])
                i += 1
                
            if len(suggested_playlists["new_playlist"]) > 2 and len(suggested_playlists["recently_played"]) > 3:
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
    """
    API endpoint retrieving all vocabulary terms completed by the active user.
    """
    permission_classes = [IsAuthenticated]
    def get(self, request):
        profile = request.user.profile
        user_words = UserWord.objects.filter(user_profile=profile).select_related('word')
        return Response({"user_word_data": UserWordSerializer(user_words, many=True).data})

class SongsListenedView(APIView):
    """
    API endpoint retrieving all songs listened to by the active user.
    """
    permission_classes = [IsAuthenticated]
    def get(self, request):
        profile = request.user.profile
        user_songs = UserSong.objects.filter(user_profile=profile).select_related('song')
        return Response({"user_song_data": UserSongSerializer(user_songs, many=True).data})

class UserActivityView(APIView):
    """
    API endpoint providing comprehensive calendar tracking details and streak data.
    """
    permission_classes = [IsAuthenticated]
    def get(self, request):
        profile = request.user.profile
        
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
    """
    API endpoint grouping user's playlists into standard chronological collections.
    """
    permission_classes = [IsAuthenticated]
    def get(self, request):
        profile = request.user.profile

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
    """
    API endpoint serving all detailed tracks for a specific user playlist.
    """
    permission_classes = [IsAuthenticated]
    def get(self, request):
        # We still need the playlist_id from the query param to know WHICH playlist to open
        playlist_id = request.query_params.get('playlist_id')
        if not playlist_id:
            return Response(status=status.HTTP_400_BAD_REQUEST)
            
        try:
            # Added a security check to make sure they own this playlist
            playlist = Playlist.objects.get(pk=playlist_id, user_profile=request.user.profile)
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

from django.utils import timezone
from datetime import timedelta

class SyncPlaylistsToSpotifyView(APIView):
    """
    API endpoint synchronizing all local playlists onto the user's linked Spotify account.

    Side Effects:
        - Refreshes expired Spotify credentials.
        - Triggers HTTP requests (POST/GET) to the Spotify Web API.
        - Creates brand new playlists on the user's Spotify account.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        from .models import SpotifyCredentials
        user = request.user

        try:
            spotify_creds = user.spotify_creds
        except SpotifyCredentials.DoesNotExist:
            return Response({"error": "Spotify not linked"}, status=status.HTTP_400_BAD_REQUEST)

        playlists = Playlist.objects.filter(user_profile=user.profile)
        synced = []
        errors = []

        for playlist in playlists:
            playlist_data, err = syncPlaylistToSpotify(playlist, spotify_creds)
            if playlist_data:
                synced.append(playlist.playlist_name)
            else:
                errors.append({"playlist": playlist.playlist_name, "error": err})

        result = {"synced": synced, "count": len(synced), "errors": errors}
        print(f"[Spotify Sync Result] {result}", flush=True)
        return Response(result, status=status.HTTP_200_OK)


class GenerateWeeklyDropView(APIView):
    """
    API endpoint generating a curated weekly language learning playlist on Spotify and locally.

    Side Effects:
        - Refreshes Spotify tokens.
        - Network integration queries Spotify API.
        - Database mutation: Creates `Playlist`, `Song`, and `PlaylistSong` records.
    """
    permission_classes = [IsAuthenticated]
    def post(self, request):
        user = request.user.profile
        django_user = request.user

        try:
            try:
                spotify_creds = django_user.spotify_creds
            except:
                return Response({"error": "Spotify not linked. Please connect your account first."}, status=status.HTTP_403_FORBIDDEN)

            # auto-Refresh the token if it's dead!
            success, err = refreshSpotifyCredentials(spotify_creds)
            if not success:
                return Response({"error": err}, status=status.HTTP_401_UNAUTHORIZED)

            access_token = spotify_creds.access_token

            # get the user's Spotify ID (Required to create a playlist)
            domain = "spo" + "tify" + ".com"
            api_base = f"https://api.{domain}/v1"
            headers = {"Authorization": f"Bearer {access_token}"}

            me_response = requests.get(f"{api_base}/me", headers=headers)

            # if we get a 401, force a token refresh and retry
            if me_response.status_code == 401:
                spotify_creds.expires_at = timezone.now() - timedelta(seconds=1)
                success, err = refreshSpotifyCredentials(spotify_creds)
                if not success:
                    return Response({"error": err}, status=status.HTTP_401_UNAUTHORIZED)
                access_token = spotify_creds.access_token
                headers = {"Authorization": f"Bearer {access_token}"}
                me_response = requests.get(f"{api_base}/me", headers=headers)

            if me_response.status_code != 200:
                return Response({"error": "Could not fetch Spotify user profile"}, status=status.HTTP_502_BAD_GATEWAY)
            spotify_user_id = me_response.json().get('id')

            # --- Austin DB LOGIC STARTS HERE ---
            weekly_songs = [
                {"title": "Despacito", "artist": "Luis Fonsi"},
                {"title": "Bidi Bidi Bom Bom", "artist": "Selena"},
                {"title": "Danza Kuduro", "artist": "Don Omar"},
                {"title": "Vivir Mi Vida", "artist": "Marc Anthony"},
                {"title": "Con Altura", "artist": "ROSALÍA"}
            ]

            track_uris = []
            db_songs = []
            for song in weekly_songs:
                result = search_spotify_track(song["title"], song["artist"], access_token)
                if result:
                    track_uris.append(f"spotify:track:{result['spotify_id']}")
                    db_song, _ = Song.objects.get_or_create(
                        spotify_id=result['spotify_id'],
                        defaults={
                            'title': result['title'],
                            'artist': result['artist'],
                            'album_art_url': result.get('album_art_url')
                        }
                    )
                    db_songs.append(db_song)
            #--- AUSTIN LOGIC ENDS HERE ---

            # create the Playlist on Spotify
            playlist_data, err = createSpotifyPlaylist(
                access_token, spotify_user_id,
                "Welcome to SongLingo!",
                "A sample platter of Jams in Spanish to whet your taste buds",
                track_uris
            )
            if not playlist_data:
                return Response({"error": err}, status=status.HTTP_502_BAD_GATEWAY)

            db_playlist = Playlist.objects.create(
                user_profile=user,
                playlist_name=playlist_data['name'],
                language=user.target_language
            )
            for db_song in db_songs:
                PlaylistSong.objects.create(playlist=db_playlist, song=db_song)

            return Response({
                "message": "weekly drop generated successfully!",
                "playlist_id": db_playlist.id,
                "spotify_url": playlist_data['external_urls']['spotify']
            }, status=status.HTTP_201_CREATED)

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def generateNewPlaylist(request):
    """
    Generates a personalized daily playlist based on active user learning parameters.

    Purpose:
        Applies algorithmic matching to select 6 songs based on difficulty level
        and selected musical genres, provisions a local Playlist representation, 
        and attempts to auto-export it directly to Spotify if credentials exist.

    Side Effects:
        - Database mutation: Creates `Playlist`, `PlaylistSong`, and `UserSong` records.
        - Integrates with Spotify APIs via remote HTTP credentials requests.
    """
    try:
        profile = request.user.profile
        django_user = request.user
        
        query_proficiency_level = getattr(profile, 'proficiency_level', 'Beginner')
        query_genres = GenreSelection.objects.filter( # this returns a list of Genre objects
            user_profile=profile
        ).values_list('genre', flat=True)
        query_language = profile.target_language

        selected_songs = []
        attempts = 0
        while len(selected_songs) < 6 and attempts < 30:
            song_query = Song.objects.exclude( # avoid songs which the user already has in MySongs
                user_song__user_profile=profile
            ).filter(
                language=query_language
            )
            # Exclude songs we have already selected in previous iterations of this loop
            if selected_songs:
                song_query = song_query.exclude(id__in=[song.id for song in selected_songs])

            if attempts < 5: # try to only get songs based on the user's preferences
                song_query = song_query.filter(
                    proficiency_level=query_proficiency_level,
                    genre__in=query_genres
                )
            elif attempts < 15: # after 5 attempts, relax the genre parameter to include songs of any genre
                song_query = song_query.filter(
                    proficiency_level=query_proficiency_level,
                )
            # after 15 attempts, no filters are used so songs could be any genre and any proficiency level

            song_pool = list(song_query)
            if song_pool:
                num_songs_needed = 6 - len(selected_songs)
                num_to_sample = min(len(song_pool), num_songs_needed)

                sampled_batch = random.sample(song_pool, num_to_sample)
                selected_songs.extend(sampled_batch)

            attempts += 1

        if len(selected_songs) == 0: # no songs found after 30 attempts
            return Response(status=status.HTTP_404_NOT_FOUND)
        
        # get most frequent genre to set as the playlists genre
        most_frequent_genre = None
        genres_in_playlist = [song.genre for song in selected_songs]
        genre_counts = Counter(genres_in_playlist)
        if genre_counts:
            most_frequent_genre = genre_counts.most_common(1)[0][0]

        date_formatted = datetime.now().strftime("%B %d")
        playlist_description = (
            f"Your daily mix for {date_formatted} consists of {len(selected_songs)} songs "
            f"primarily in the {most_frequent_genre} genre and is perfect for a "
            f"{profile.proficiency_level} {profile.target_language} learner."
        )
        
        playlist = Playlist.objects.create( # THIS SHOULD BE UPDATED AFTER FIGURING OUT HOW TO GENERATE NAME AND DESCRIPTION, ETC.
            user_profile=profile,
            playlist_name="Your Daily Mix",
            language=profile.target_language,
            genre=most_frequent_genre,
            description=playlist_description,
            proficiency_level=profile.proficiency_level
        )

        PlaylistSong.objects.bulk_create([
            PlaylistSong(playlist=playlist, song=song) 
            for song in selected_songs
        ])

        UserSong.objects.bulk_create([
            UserSong(user_profile=profile, song=song)
            for song in selected_songs
        ])

        spotify_url = None

        # We wrap this in a try/except so if Spotify fails, the user still gets
        # their local SongLingo playlist without the app crashing!
        try:
            if hasattr(django_user, 'spotify_creds'):
                spotify_creds = django_user.spotify_creds

                # 1. Auto-Refresh Token
                success, err = refreshSpotifyCredentials(spotify_creds)
                if not success:
                    print(f"Spotify Export: token refresh failed — {err}")
                else:
                    playlist_data, err = syncPlaylistToSpotify(playlist, spotify_creds)
                    if playlist_data:
                        spotify_url = playlist_data['external_urls']['spotify']
                    else:
                        print(f"Spotify Export: sync failed — {err}")

        except Exception as spotify_error:
            print(f"Spotify Export Failed: {spotify_error}")

        # Return Austin's payload, plus the new Spotify link
        return Response({
            "playlist": PlaylistSerializer(playlist).data,
            "spotify_url": spotify_url 
        }, status=status.HTTP_201_CREATED)
    
    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
# ==========================================
# PROGRESS UPDATERS
# ==========================================

@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def updateUserWordNumPracticesCompleted(request):
    """
    Updates progress history count for a given studied vocabulary word.

    Side Effects:
        - Database mutation: Increments `num_practices_completed` on UserWord record.
        - Network query: Resolves dictionary API details if the word is new.
    """
    profile = request.user.profile
    word_text = request.query_params.get('word_text')
    if not word_text:
        return Response(status=status.HTTP_400_BAD_REQUEST)
    
    updateUserActivity(profile.id)

    word_text = clean_and_format_word(word_text)
    word_obj = Word.objects.filter(word_text=word_text).first()

    if word_obj == None: # Word is not in the DB
        print("fetching word info from external API")

        word_info = fetch_word_info(word_text)
        word_obj = Word.objects.create(
            language=Language.objects.get(language_name='Spanish'),
            word_text=word_text,
            translation=word_info["definition"] if word_info else "",
            pronunciation=word_info["pronunciation"] if word_info else "",
            definition=word_info["definition"] if word_info else ""
        )
        print(f"word_text: {word_obj.word_text}")
        print(f"translation: {word_obj.translation}")
        print(f"pronunciation: {word_obj.pronunciation}")
        print(f"definition: {word_obj.definition}")
    else:
        print("word_obj existed")

    rows_updated = UserWord.objects.filter(user_profile=profile, word=word_obj).update(
        num_practices_completed=F('num_practices_completed') + 1
    )

    # If the UserWord object doesn't exist yet (first time the user practiced this word)
    if rows_updated == 0:
        UserWord.objects.create(
            user_profile=profile,
            word=word_obj,
            num_practices_completed=1
        )
        rows_updated = 1

    return Response({"rows_updated": rows_updated}, status=status.HTTP_200_OK)

@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def updateUserSongProgress(request):
    """
    Updates completion and listening progress statistics for a song.

    Side Effects:
        - Database mutation: Mutates UserSong and Playlist listening stats.
    """
    profile = request.user.profile
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
def getWordCardExercise(request):
    """
    Assembles a set of 10 vocabulary terms and multiple-choice translation options.
    """ # returns the user's 10 least practiced words and their relevant info
    user_profile_id = UserProfile.objects.get(user=request.user).pk

    if user_profile_id == None:
        return Response(status=status.HTTP_400_BAD_REQUEST)

    practice_words = []
    word_set = set()
    attempts = 50
    while len(practice_words) < 10 and attempts > 0:
        random_user_song = getPracticeExerciseSong(user_profile_id)
        song_words = get_unique_words_from_lyrics(random_user_song.lyrics)
        
        for word in song_words:
            cleaned_word = clean_and_format_word(word)
            word_set.add(cleaned_word)

        # This line ensures that the words we are sending back are in the DB and have a translation, etc.
        practice_words.extend(list(Word.objects.filter(word_text__in=word_set)))
        
        if len(practice_words) >= 10:
            practice_words = practice_words[:10]
            break # We have our 10 valid words, we can stop entirely!
            
        attempts -= 1

    word_distractors = []
    for word in practice_words:
        distractors = getEnglishWordDistractors(user_profile_id, word.translation)
        word_distractors.append(distractors)

    practice_words_serialized = WordCardSerializer(practice_words, many=True).data
    return Response(
        {"practice_words": practice_words_serialized,
         "word_distractors": word_distractors
        },
        status=status.HTTP_200_OK
    )

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def getCompleteTheLyricExercise(request):
    """
    Generates a lyric challenge containing a randomly selected line with a blanked word.
    """
    profile = request.user.profile
    practice_song = getPracticeExerciseSong(profile.id)

    attempts = 20
    lyric_and_word = ["", ""]
    while (lyric_and_word[0] == "" or lyric_and_word[1] == "") and attempts > 0:
        lyric_and_word = getLyricAndMissingWord(practice_song)
        attempts -=1

    distractor_words = getSongDistractorWords(practice_song, lyric_and_word[1])

    return Response({
        "song_id": practice_song.pk,
        "lyric": lyric_and_word[0],
        "missing_word": lyric_and_word[1],
        "distractor_words": distractor_words,
        "song_title": practice_song.title,
        "song_artist": practice_song.artist
    })

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def getLyricMatchExercise(request):
    """
    Generates a matching challenge for two consecutive song lines.
    """
    profile = request.user.profile
    practice_song = getPracticeExerciseSong(profile.id)
    two_song_lines = getTwoRandomSongLines(practice_song)
    
    return Response({
        "song_id": practice_song.pk,
        "line_to_display": two_song_lines[0],
        "line_to_match": two_song_lines[1],
        "song_title": practice_song.title,
        "song_artist": practice_song.artist
    })

# ==========================================
# FAST MCP PROXY
# ==========================================

class PronunciationView(APIView):
    """
    Generates high-quality base64 Spanish pronunciation audio using gTTS.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request, word):
        try:
            # 1. Your phonetic logic goes here (currently just a dummy placeholder!)
            dummy_phonetic = f"/{word.lower()}/"
            
            # 2. Generate the native audio using gTTS
            tts = gTTS(text=word, lang="es", tld="com.mx")
            
            # 3. The "pro" move: save to memory instead of the hard drive
            audio_fp = io.BytesIO()
            tts.write_to_fp(audio_fp)
            
            # 4. Convert the raw audio to a base64 string
            audio_base64 = base64.b64encode(audio_fp.getvalue()).decode('utf-8')
            
            # 5. Return the exact JSON structure Jaci's Swift struct expects
            return Response({
                "phonetic": dummy_phonetic,
                "audio": audio_base64
            }, status=200)
            
        except Exception as e:
            return Response({"error": str(e)}, status=500)

@api_view(['GET'])
@permission_classes([AllowAny])
async def get_pronunciation(request, word):
    """
    Asynchronously proxies audio calls to remote FastMCP tools.
    """
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

#The Helper: Generates the login link for the Swift frontend
class SpotifyAuthURLView(APIView):
    """
    Supplies the URL needed to authorize the Swift client for Spotify interactions.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        from urllib.parse import urlencode
        client_id = os.getenv('SPOTIFY_CLIENT_ID', '').strip(' "\'')
        redirect_uri = "songlingo://spotify-callback"
        scope = "playlist-modify-public playlist-modify-private playlist-read-private user-read-email"

        domain = "spo" + "tify" + ".com"

        params = urlencode({
            'client_id': client_id,
            'response_type': 'code',
            'redirect_uri': redirect_uri,
            'scope': scope
        })
        url = f"https://accounts.{domain}/authorize?{params}"

        return Response({"auth_url": url}, status=200)

from .models import SpotifyCredentials
class SpotifyMobileCallbackView(APIView):
    """
    Exchanges mobile auth code callback tokens to securely save credentials.

    Side Effects:
        - Mutates SpotifyCredentials vault.
    """
    permission_classes = [IsAuthenticated] 
    
    def post(self, request):
        code = request.data.get('code')
        
        if not code:
            return Response({"error": "No authorization code provided"}, status=400)
            
        # Standard Spotify Token Endpoint
        token_url = "https://accounts.spotify.com/api/token"
        
        redirect_uri = "songlingo://spotify-callback" 

        data = {
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirect_uri,
        }
        
        client_id = os.getenv('SPOTIFY_CLIENT_ID', '').strip(' "\'')
        client_secret = os.getenv('SPOTIFY_CLIENT_SECRET', '').strip(' "\'')
        
        # Trade the code for the tokens
        response = requests.post(token_url, data=data, auth=(client_id, client_secret))
        
        if response.status_code != 200:
            return Response({"error": "Spotify rejected the code trade", "details": response.text}, status=400)
            
        token_data = response.json()
        
        # calculate exactly when this token dies
        expires_in = token_data.get('expires_in', 3600)
        expires_at = timezone.now() + timedelta(seconds=expires_in)
        
        # Fetch the user's Spotify ID while we have a fresh token
        access_token = token_data.get('access_token')
        domain = "spo" + "tify" + ".com"
        me_resp = requests.get(
            f"https://api.{domain}/v1/me",
            headers={"Authorization": f"Bearer {access_token}"}
        )
        spotify_id = me_resp.json().get('id') if me_resp.status_code == 200 else None

        # Lock it in the Vault! (update_or_create means they can re-link safely if needed)
        SpotifyCredentials.objects.update_or_create(
            user=request.user,
            defaults={
                'spotify_id': spotify_id,
                'access_token': access_token,
                'refresh_token': token_data.get('refresh_token'),
                'expires_at': expires_at
            }
        )

        return Response({"status": "success", "message": "Spotify successfully linked!"})