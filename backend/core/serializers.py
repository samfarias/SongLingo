from rest_framework import serializers
from .models import (
    Language, Genre, UserProfile, GenreSelection, UserActivity, DaysActive,
    Word, UserWords, Song, SongGenres, UserSongs, Playlist, PlaylistSongs,
    PlaylistGenres, PlaylistDaysListened
)

########################
# Supporting Model Serializers
########################

class LanguageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Language
        fields = '__all__'

class GenreSerializer(serializers.ModelSerializer):
    class Meta:
        model = Genre
        fields = '__all__'


########################
# User Model Serializers
########################

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = '__all__'

class GenreSelectionSerializer(serializers.ModelSerializer):
    class Meta:
        model = GenreSelection
        fields = '__all__'

class UserActivitySerializer(serializers.ModelSerializer):
    class Meta:
        model = UserActivity
        fields = '__all__'

class DaysActiveSerializer(serializers.ModelSerializer):
    class Meta:
        model = DaysActive
        fields = '__all__'


########################
# Word Model Serializers
########################

class WordSerializer(serializers.ModelSerializer):
    class Meta:
        model = Word
        fields = '__all__'

class UserWordsSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserWords
        fields = '__all__'


########################
# Song Model Serializers
########################

class SongSerializer(serializers.ModelSerializer):
    class Meta:
        model = Song
        fields = '__all__'

class SongGenresSerializer(serializers.ModelSerializer):
    class Meta:
        model = SongGenres
        fields = '__all__'

class UserSongsSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserSongs
        fields = '__all__'


########################
# Playlist Model Serializers
########################

class PlaylistSerializer(serializers.ModelSerializer):
    class Meta:
        model = Playlist
        fields = '__all__'

class PlaylistSongsSerializer(serializers.ModelSerializer):
    class Meta:
        model = PlaylistSongs
        fields = '__all__'

class PlaylistGenresSerializer(serializers.ModelSerializer):
    class Meta:
        model = PlaylistGenres
        fields = '__all__'

class PlaylistDaysListenedSerializer(serializers.ModelSerializer):
    class Meta:
        model = PlaylistDaysListened
        fields = '__all__'