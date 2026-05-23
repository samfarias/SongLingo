"""
Module: serializers
Description: Django REST Framework serializers transforming database model instances
             into structured JSON formats and validating registration and authentication payloads.
"""
from rest_framework import serializers
from django.contrib.auth.models import User
from .models import (
    Language, Genre, UserProfile, GenreSelection, UserActivity, DaysActive,
    Word, UserWord, Song, UserSong, Playlist, PlaylistSong
)
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework_simplejwt.views import TokenObtainPairView

########################
# Supporting Model Serializers
########################


class LanguageSerializer(serializers.ModelSerializer):
    """
    Serializes Language database instances to JSON.
    """
    class Meta:
        model = Language
        fields = '__all__'

class GenreSerializer(serializers.ModelSerializer):
    """
    Serializes Genre database instances to JSON.
    """
    class Meta:
        model = Genre
        fields = '__all__'


########################
# User Model Serializers
########################

class UserProfileSerializer(serializers.ModelSerializer):
    """
    Serializes UserProfile details, including computed profile join date and genre list.
    """
    join_date = serializers.DateTimeField(source='user.date_joined', format="%B %Y", read_only=True)

    genres = serializers.SerializerMethodField()

    def get_genres(self, obj):
        """
        Computes the list of selected genre names for the user profile.
        """
        return list(obj.genre_selections.values_list('genre__genre_name', flat=True))

    class Meta:
        model = UserProfile
        fields = [
            'id',
            'first_name',
            'last_name',
            'target_language',
            'proficiency_level',
            'user_level',
            'join_date',
            'genres'
        ]

    def to_representation(self, instance):
        """
        Modifies representation to fall back to username/empty string if names are null.
        """
        data = super().to_representation(instance)
        data['first_name'] = data['first_name'] or instance.user.username
        data['last_name'] = data['last_name'] or ""
        return data

class GenreSelectionSerializer(serializers.ModelSerializer):
    """
    Serializes GenreSelection model linkages.
    """
    class Meta:
        model = GenreSelection
        fields = '__all__'

class UserActivitySerializer(serializers.ModelSerializer):
    """
    Serializes UserActivity progress tracking records.
    """
    class Meta:
        model = UserActivity
        fields = ['user_profile', 'current_streak', 'longest_streak']

class DaysActiveSerializer(serializers.ModelSerializer):
    """
    Serializes Dates representing user activity logging.
    """
    class Meta:
        model = DaysActive
        fields = ['date']

class UserRegistrationSerializer(serializers.ModelSerializer):
    """
    Validates and registers new auth User accounts and profile associations.
    """
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ('username', 'password')

    def create(self, validated_data):
        """
        Creates a new User account, setting default profile values.
        """
        # 1. This saves the user AND instantly triggers the post_save signal
        user = User.objects.create_user(
            username=validated_data['username'],
            password=validated_data['password'],
        )
        
        # 2. The signal just created the profile, so we safely grab it and update the defaults
        profile, _ = UserProfile.objects.get_or_create(user=user)
        profile.first_name = validated_data['username']
        profile.last_name = ""
        profile.target_language_id = 1
        profile.proficiency_level = "Beginner"
        profile.save()
        
        return user

########################
# Word Model Serializers
########################

class WordSerializer(serializers.ModelSerializer):
    """
    Serializes standard Word dictionary terms.
    """
    class Meta:
        model = Word
        fields = '__all__'

class UserWordSerializer(serializers.ModelSerializer):
    """
    Serializes a user's studied vocabulary terms, nesting word dictionary details.
    """
    class WordsLearnedScreenWordSerializer(serializers.ModelSerializer):
        """
        Sub-serializer supplying nested translation and word text fields.
        """
        class Meta:
            model = Word
            fields = ['word_text', 'translation']

    word = WordsLearnedScreenWordSerializer(read_only=True) # This nests the Word data inside the UserWord object

    class Meta:
        model = UserWord
        fields = ['word', 'num_listens', 'num_practices_completed', 'mastery_lvl']

class WordCardSerializer(serializers.ModelSerializer):
    """
    Serializes comprehensive word cards metadata including user's progress.
    """
    num_practices_completed = serializers.IntegerField(read_only=True)
    mastery_lvl = serializers.IntegerField(read_only=True)

    class Meta:
        model = Word
        fields = ['word_text', 'translation', 'pronunciation', 'definition', 'num_practices_completed', 'mastery_lvl']


########################
# Song Model Serializers
########################

class SongSerializer(serializers.ModelSerializer):
    """
    Serializes standard Song items.
    """
    class Meta:
        model = Song
        fields = '__all__'

class UserSongSerializer(serializers.ModelSerializer):
    """
    Serializes songs listened to by the user, nesting song details.
    """
    class SongsListenedScreenSongSerializer(serializers.ModelSerializer):
        """
        Sub-serializer supplying basic song title and artist information.
        """
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
    """
    Serializes Playlist metadata objects.
    """
    class Meta:
        model = Playlist
        fields = '__all__'

class PlaylistCollectionSerializer(serializers.ModelSerializer):
    """
    Serializes Playlists structured into collection feeds.
    """
    class Meta:
        model = Playlist
        fields = '__all__'

class PlaylistSongSerializer(serializers.ModelSerializer):
    """
    Serializes songs linked within a playlist, nesting their details.
    """
    class SinglePlaylistScreenSongSerializer(serializers.ModelSerializer):
        """
        Sub-serializer supplying nested track name, artist, difficulty, and genre.
        """
        class Meta:
            model = Song
            fields = ['title', 'artist', 'proficiency_level', 'genre', 'spotify_id', 'spotify_preview_url', 'album_art_url']

    song = SinglePlaylistScreenSongSerializer(read_only=True) # This nests the Song data inside the PlaylistSong object

    class Meta:
        model = PlaylistSong
        fields = ['song']

class SuggestedPlaylistsSerializer(serializers.ModelSerializer):
    """
    Serializes high-level playlist suggestions shown on the home dashboard.
    """
    class Meta:
        model = Playlist
        fields = ['id', 'playlist_name', 'language', 'genre', 'last_date_played', 'created_date', 'proficiency_level']

class MyTokenObtainPairSerializer(TokenObtainPairSerializer):
    """
    Custom JWT Token generator packing profile summary info into responses.
    """
    def validate(self, attrs):
        """
        Appends user profile target language and proficiency level to token response data.
        """
        data = super().validate(attrs)
        # Pack the extra data into the JSON response
        data['first_name'] = self.user.first_name
        data['target_language'] = self.user.profile.target_language
        data['proficiency_level'] = self.user.profile.proficiency_level
        return data
    
class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    """
    Custom JWT Token generator fallback-proofing responses with profile parameters.
    """
    def validate(self, attrs):
        """
        Injects normalized first name, target language name, profile ID, and difficulty tier.
        """
        data = super().validate(attrs)
        
        # FIX: Changed 'userprofile' to 'profile'
        profile = getattr(self.user, 'profile', None)
        
        if profile:
            # Send the profile ID
            data['user_id'] = profile.id 
            data['first_name'] = profile.first_name or "User"
            data['target_language'] = profile.target_language.language_name if profile.target_language else "Language"
            data['proficiency_level'] = profile.proficiency_level
        else:
            data['user_id'] = self.user.id
            data['first_name'] = "User"
            data['target_language'] = "Language"
            data['proficiency_level'] = "Beginner"
            
        return data