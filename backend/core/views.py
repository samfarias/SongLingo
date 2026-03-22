from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework import status
from .models import (
  UserProfile, Song, UserWords, UserSongs, UserActivity, DaysActive, Playlist,
  PlaylistSongs
)
from .serializers import (
    SongSerializer, UserProfileSerializer, UserWordsSerializer, UserSongsSerializer,
    UserActivitySerializer, DaysActiveSerializer, PlaylistSerializer, PlaylistSongsSerializer,
    PlaylistCollectionSerializer
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
        num_words_learned = UserWords.objects.filter(user_profile=user_id).count()
        num_songs_completed = UserSongs.objects.filter(user_profile=user_id).count()
        current_streak = UserActivity.objects.get(user_profile=user_id).current_streak
        user_progress = {
            "num_words_learned": num_words_learned,
            "num_songs_completed": num_songs_completed,
            "current_streak": current_streak
        }

        # daily recommended song
   
        # recent_playlists (returns the 3 most recently listened to playlists)
        
        
        # JSON response for Swift frontend
        return Response({
            "user_info": user_profile_info,
            "user_progress": user_progress
        })
    

class WordsLearnedView(APIView):
    def get(self, request): # returns all data for the user's "Words Learned" screen
        
        user_id = request.query_params.get('user_id', None)
        if user_id == None:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        user_words = UserWords.objects.filter(user_profile=user_id).select_related('word')
        user_word_data = UserWordsSerializer(user_words, many=True).data
        return Response({"user_word_data": user_word_data})


class SongsListenedView(APIView):
    def get(self, request): # returns all data for the user's "Songs Listened" screen

        user_id = request.query_params.get('user_id', None)
        if user_id == None:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        user_songs = UserSongs.objects.filter(user_profile=user_id).select_related('song')
        user_song_data = UserSongsSerializer(user_songs, many=True).data
        return Response({"user_song_data": user_song_data})


class UserActivityView(APIView):
    def get(self, request): # returns all data for the user's "Activity" screen (streak/calendar)

        user_id = request.query_params.get('user_id', None)
        if user_id == None:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        user_activity = UserActivity.objects.get(user_profile=user_id)
        user_activity_data = UserActivitySerializer(user_activity).data # contains streak info

        days_active = DaysActive.objects.filter(user_profile=user_id)
        days_active_data = DaysActiveSerializer(days_active, many=True).data

        return Response({"streak_info": user_activity_data,
                         "days_active": days_active_data})


class PlaylistCollectionView(APIView):
    def get(self, request): # returns all data for the user's "Playlist Collection" screen
        
        user_id = request.query_params.get('user_id', None)
        if user_id == None:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        sql_query = "SELECT " \
        "               p.id, p.playlist_name, p.genre_id, p.proficiency_level, p.last_date_played " \
        "           FROM core_playlist AS p" \
        "           WHERE p.user_profile_id = %s" \
        "           GROUP BY p.id, p.playlist_name, p.genre_id, p.proficiency_level" \
        "           ORDER BY p.last_date_played DESC"
        user_playlists = Playlist.objects.raw(sql_query, [user_id]) # all user's playlists sorted by last_played_date descending
        playlists_and_date_info = PlaylistCollectionSerializer(user_playlists, many=True).data

        # NEXT: split playlists in the playlist categories

        return Response({"playlist_collection_data": playlists_and_date_info})
    
    

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
        playlist_songs = PlaylistSongs.objects.filter(playlist=playlist_id).select_related('song')
        playlist_song_data = PlaylistSongsSerializer(playlist_songs, many=True).data

        return Response({"playlist_info": playlist_info,
                         "playlist_songs": playlist_song_data})




@api_view(['GET'])
def getSongs(request):
    language_filter = request.query_params.get('language', None)
    songs = Song.objects.filter(language=language_filter) if language_filter else Song.objects.all()
    serializer = SongSerializer(songs, many=True)
    return Response({"songs": serializer.data})
    
@api_view(['POST'])
def createSong(request):
    serializer = SongSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)