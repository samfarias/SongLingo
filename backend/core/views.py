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

load_dotenv(find_dotenv())

from .models import (
  UserProfile, Song, UserWord, UserSong, UserActivity, DaysActive, Playlist,
  PlaylistSong, Word
)
from .serializers import (
    SongSerializer, UserProfileSerializer, UserWordSerializer, UserSongSerializer,
    UserActivitySerializer, DaysActiveSerializer, PlaylistSerializer, PlaylistSongSerializer,
    PlaylistCollectionSerializer, SuggestedPlaylistsSerializer
)
from .views_helpers import (
    updateUserActivity, updateUserPlaylistNumSongListens
)

class HomeScreenView(APIView):
    def get(self, request): # returns all data for the user's Home Screen

        # user_info
        user_id = request.query_params.get('user_id', None)
        if user_id == None:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        try:
            user_profile = UserProfile.objects.get(pk=user_id)
        except UserProfile.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
        
        user_profile_info = UserProfileSerializer(user_profile).data

        # user_progress
        num_words_learned = UserWord.objects.filter(user_profile=user_id).count()
        num_songs_completed = UserSong.objects.filter(user_profile=user_id).count()
        current_streak = UserActivity.objects.get(user_profile=user_id).current_streak
        user_progress = {
            "num_words_learned": num_words_learned,
            "num_songs_completed": num_songs_completed,
            "current_streak": current_streak
        }
   
        # suggested_playlists (returns 3 playlists: 2 recently_played and 1 new_playlist IF new_playlist exists, else 3 recently_played)
        user_playlists = list(Playlist.objects.filter(user_profile=user_id).order_by('-last_date_played', '-created_date'))
        def getSuggestedPlaylists(user_playlists: list[Playlist]) -> dict[str, list[Playlist]]:
            suggested_playlists = { # returns 3 total playlists: 2 recent and 1 new IF new exists, else 3 recent
                "recently_played": [],
                "new_playlist": []
            }
            # get new_playlist if there is one, and move index past new_playlists and to up to recently_listened playlists
            i = 0
            while i < len(user_playlists) and user_playlists[i].last_date_played == None:
                if len(suggested_playlists["new_playlist"]) == 0:
                    suggested_playlists["new_playlist"].append(user_playlists[i])
                i += 1
            # append up to 3 recently_played playlists and afterwards pop() 1 recently_played if a new_playlist exists
            while i < len(user_playlists) and len(suggested_playlists["recently_played"]) < 3:
                suggested_playlists["recently_played"].append(user_playlists[i])
                i += 1
            if len(suggested_playlists["new_playlist"]) > 0 and len(suggested_playlists["recently_played"]) >= 3:
                suggested_playlists["recently_played"].pop()
            return suggested_playlists
        suggested_playlists = getSuggestedPlaylists(user_playlists=user_playlists)
        recently_played_serialized = SuggestedPlaylistsSerializer(suggested_playlists["recently_played"], many=True).data
        new_playlist_serialized = SuggestedPlaylistsSerializer(suggested_playlists["new_playlist"], many=True).data

        # (NEXT feature) daily recommended song
        
        # JSON response for Swift frontend
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