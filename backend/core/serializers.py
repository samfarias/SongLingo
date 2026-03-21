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
        fields = ['user_profile_id', 'current_streak', 'longest_streak']

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

class UserWordsSerializer(serializers.ModelSerializer):
    class WordsLearnedScreenWordSerializer(serializers.ModelSerializer):
        class Meta:
            model = Word
            fields = ['word_text', 'translation']

    word = WordsLearnedScreenWordSerializer(read_only=True) # This nests the Word data inside the UserWord object

    class Meta:
        model = UserWords
        fields = ['word', 'num_listens', 'num_practices_completed', 'mastery_lvl']


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
    class SongsListenedScreenSongSerializer(serializers.ModelSerializer):
        class Meta:
            model = Song
            fields = ['title', 'artist']

    song = SongsListenedScreenSongSerializer(read_only=True) # This nests the Song data inside the UserSongs object

    class Meta:
        model = UserSongs
        fields = ['song', 'num_listens', 'num_lyric_challenges_completed', 'mastery_lvl']


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