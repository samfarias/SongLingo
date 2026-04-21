from rest_framework import serializers
from .models import (
    Language, Genre, UserProfile, GenreSelection, UserActivity, DaysActive,
    Word, UserWord, Song, UserSong, Playlist, PlaylistSong
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
        fields = ['user_profile', 'current_streak', 'longest_streak']

class DaysActiveSerializer(serializers.ModelSerializer):
    class Meta:
        model = DaysActive
        fields = ['date']


########################
# Word Model Serializers
########################

class WordSerializer(serializers.ModelSerializer):
    class Meta:
        model = Word
        fields = '__all__'

class UserWordSerializer(serializers.ModelSerializer):
    class WordsLearnedScreenWordSerializer(serializers.ModelSerializer):
        class Meta:
            model = Word
            fields = ['word_text', 'translation']

    word = WordsLearnedScreenWordSerializer(read_only=True) # This nests the Word data inside the UserWord object

    class Meta:
        model = UserWord
        fields = ['word', 'num_listens', 'num_practices_completed', 'mastery_lvl']

class WordCardSerializer(serializers.ModelSerializer):
    num_practices_completed = serializers.IntegerField(read_only=True)
    mastery_lvl = serializers.IntegerField(read_only=True)

    class Meta:
        model = Word
        fields = ['word_text', 'translation', 'pronunciation', 'definition', 'num_practices_completed', 'mastery_lvl']


########################
# Song Model Serializers
########################

class SongSerializer(serializers.ModelSerializer):
    class Meta:
        model = Song
        fields = '__all__'

class UserSongSerializer(serializers.ModelSerializer):
    class SongsListenedScreenSongSerializer(serializers.ModelSerializer):
        class Meta:
            model = Song
            fields = ['title', 'artist']

    song = SongsListenedScreenSongSerializer(read_only=True) # This nests the Song data inside the UserSong object

    class Meta:
        model = UserSong
        fields = ['song', 'num_listens', 'num_lyric_challenges_completed', 'mastery_lvl']


########################
# Playlist Model Serializers
########################

class PlaylistSerializer(serializers.ModelSerializer):
    class Meta:
        model = Playlist
        fields = '__all__'

class PlaylistCollectionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Playlist
        fields = ['playlist_name', 'genre', 'proficiency_level', 'last_date_played']

class PlaylistSongSerializer(serializers.ModelSerializer):
    class SinglePlaylistScreenSongSerializer(serializers.ModelSerializer):
        class Meta:
            model = Song
            fields = ['title', 'artist', 'proficiency_level', 'genre']

    song = SinglePlaylistScreenSongSerializer(read_only=True) # This nests the Song data inside the PlaylistSong object

    class Meta:
        model = PlaylistSong
        fields = ['song']

class SuggestedPlaylistsSerializer(serializers.ModelSerializer):
    class Meta:
        model = Playlist
        fields = ['playlist_name', 'language', 'genre', 'last_date_played', 'created_date', 'proficiency_level']