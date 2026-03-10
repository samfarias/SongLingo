from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
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
