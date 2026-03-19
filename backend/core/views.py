from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework import status
from .models import UserProfile, Song
from .serializers import SongSerializer

class HomeStatusView(APIView):
    def get(self, request):
        # 1. Get a user profile (hardcoding the first one in the DB to test)
        # In the future, this will use actual authentication
        profile = UserProfile.objects.first() 
        
        # 2. Get a recommended song (Just grabbing the first one for now)
        # This is where we'll build the "difficulty algorithm" later
        recommended_song = Song.objects.first()
        
        # 3. Serialize the song into JSON (so Swift can understand it)
        song_data = SongSerializer(recommended_song).data if recommended_song else None
        
        # 4. Construct the exact JSON Swift is expecting
        return Response({
            "current_streak": profile.current_streak if profile else 0,
            "recommended_song": song_data
        })


@api_view(['GET'])
def getSongs(request):
    songs = Song.objects.all()
    serializer = SongSerializer(songs, many=True)
    return Response({"songs": serializer.data})
    
@api_view(['POST'])
def createSong(request):
    if request.method == 'POST':
        serializer = SongSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)