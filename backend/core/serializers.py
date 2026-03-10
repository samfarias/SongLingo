# core/serializers.py
from rest_framework import serializers
from .models import Song

class SongSerializer(serializers.ModelSerializer):
    class Meta:
        model = Song
        # These are the fields the Swift app will receive in the JSON
        fields = ['id', 'title', 'artist', 'genre', 'preview_url', 'difficulty_level']