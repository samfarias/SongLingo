from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework import status
from .models import UserProfile, Song, UserWords, UserSongs, UserActivity
from .serializers import SongSerializer, UserProfileSerializer, UserActivitySerializer

class HomeScreenView(APIView):
    def get(self, request): # provides the frontend with all of the data for the home screen

        # user_info
        user_id = request.query_params.get('user_id', None)
        if user_id == None:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        try:
            user_profile = UserProfile.objects.get(pk=user_id)
        except UserProfile.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
        
        user_info = UserProfileSerializer(user_profile).data

        # user_progress
        num_words_learned = UserWords.objects.filter(user_profile_id=user_id).count()
        num_songs_completed = UserSongs.objects.filter(user_profile_id=user_id).count()
        current_streak = UserActivity.objects.get(user_profile_id=user_id).current_streak
        user_progress = {
            "num_words_learned": num_words_learned,
            "num_songs_completed": num_songs_completed,
            "current_streak": current_streak
        }

        # daily recommended song
   
        # current/suggested Playlists
        
        # JSON response for Swift frontend
        return Response({
            "user_info": user_info,
            "user_progress": user_progress
        })


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