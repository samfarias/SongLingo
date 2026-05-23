"""
Module: models
Description: Core database models for the SongLingo Django application, encapsulating 
             user profiles, gamified progress, songs, words, playlists, and 
             Spotify API credentials.
"""
from django.db import models
from django.contrib.auth.models import User
from datetime import date


########################
# Supporting models
########################

class Language(models.Model):
    """
    Represents a language supported by the application.
    """
    language_name = models.CharField(max_length=100)

    def __str__(self):
        return self.language_name

class Genre(models.Model):
    """
    Represents a musical genre (e.g., Pop, Rock, Reggaeton/Urbano).
    """
    genre_name = models.CharField(max_length=100)

    def __str__(self):
        return self.genre_name

########################
# User models
########################

class UserProfile(models.Model):
    """
    Represents extended user profile metadata linked to Django's Auth User.

    Fields:
        user: One-to-one link to auth.User.
        first_name: First name of the user.
        last_name: Last name of the user.
        target_language: Foreign key to Language indicating the language they want to learn.
        proficiency_level: User's selected difficulty tier ('Beginner', 'Intermediate', 'Advanced').
        user_level: Current level in the gamified progress system.
    """
    # Links this profile to the built-in Django Auth system
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile', null=True, blank=True)

    first_name = models.CharField(max_length=100, null=True)
    last_name = models.CharField(max_length=100, null=True)
    target_language = models.ForeignKey(Language, on_delete=models.SET_NULL, null=True, related_name='users')
    proficiency_level = models.CharField( # language proficiency level
        max_length=20, 
        choices=[('Beginner', 'Beginner'), ('Intermediate', 'Intermediate'), ('Advanced', 'Advanced')],
        default='Beginner'
    )
    user_level = models.IntegerField(default=0) # gamified progress level

    def __str__(self):
        return f"{self.first_name} {self.last_name}"

class GenreSelection(models.Model):
    """
    Represents a user's selected musical genre preference.
    Serves as a join table linking UserProfile and Genre models.
    """
    user_profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='genre_selections')
    genre = models.ForeignKey(Genre, on_delete=models.CASCADE, related_name='genre_selections')

    def __str__(self):
        return f"{self.user_profile} - {self.genre}"


class UserActivity(models.Model):
    """
    Tracks daily streak information for a user.

    Fields:
        user_profile: Foreign key to UserProfile.
        current_streak: Number of consecutive active days.
        longest_streak: Maximum streak milestone achieved.
    """
    user_profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='activities')
    current_streak = models.IntegerField(default=0)
    longest_streak = models.IntegerField(default=0)

    def __str__(self):
        return f"Activity for {self.user_profile}"


class DaysActive(models.Model):
    """
    Logs specific calendar dates when the user performed an activity.
    """
    user_profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='days_active')
    date = models.DateField()

    def __str__(self):
        return f"{self.user_profile} active on {self.date}"

########################
# Word models
########################

class Word(models.Model):
    """
    Represents a vocabulary term in a target language.

    Fields:
        language: Language of the word.
        word_text: The vocabulary text in the foreign language.
        translation: English translation of the word.
        pronunciation: Phonetic pronunciation details.
        definition: Full dictionary definition or helper context.
        lexical_category: Part of speech (e.g., Noun, Verb).
        proficiency_level: Associated difficulty tier.
    """
    language = models.ForeignKey(Language, on_delete=models.CASCADE, related_name='words')
    word_text = models.CharField(max_length=200)
    translation = models.CharField(max_length=200)
    pronunciation = models.CharField(max_length=200, blank=True)
    definition = models.TextField(blank=True)
    lexical_category = models.CharField(max_length=100, blank=True) # Noun, verb, phrase, etc.
    proficiency_level = models.CharField(
        max_length=20, 
        choices=[('Beginner', 'Beginner'), ('Intermediate', 'Intermediate'), ('Advanced', 'Advanced')],
        default='Beginner'
    )

    def __str__(self):
        return f"{self.word_text} ({self.translation})"

class UserWord(models.Model):
    """
    Tracks a user's progress and practice history for a specific word.

    Fields:
        user_profile: Target user profile.
        word: Reference to the Word model.
        num_listens: Count of times the user listened to the word.
        num_practices_completed: Count of vocabulary card practices.
        mastery_lvl: User's calculated mastery progress.
    """
    user_profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='user_word')
    word = models.ForeignKey(Word, on_delete=models.CASCADE, related_name='user_word')
    num_listens = models.IntegerField(default=0)
    num_practices_completed = models.IntegerField(default=0)
    mastery_lvl = models.IntegerField(default=0)

    def __str__(self):
        return f"{self.user_profile} - {self.word}"

########################
# Song models
########################

class Song(models.Model):
    """
    Represents a learning song loaded in the database.

    Fields:
        title: Title of the track.
        artist: Name of the artist.
        spotify_id: Corresponding track ID on Spotify.
        language: Target foreign language.
        genre: Musical genre classification.
        vocabulary_json: List of target vocabulary words extracted from lyrics.
        spotify_preview_url: URL link to a 30-second audio clip preview.
        lyrics: Cleaned text transcription of song lyrics.
        proficiency_level: Associated difficulty tier.
    """
    title = models.CharField(max_length=200)
    artist = models.CharField(max_length=200)
    spotify_id = models.CharField(max_length=100, unique=True, null=True, blank=True)
    language = models.ForeignKey(Language, null=True, on_delete=models.CASCADE, related_name='song')
    genre = models.ForeignKey(Genre, null=True, on_delete=models.SET_NULL, related_name='song')
    vocabulary_json = models.JSONField(default=list, blank=True)
    spotify_preview_url = models.URLField(blank=True, null=True, help_text="Direct link to  audio clip")
    album_art_url = models.URLField(blank=True, null=True)
    lyrics = models.TextField(blank=True)
    proficiency_level = models.CharField(
        max_length=20,
        choices=[('Beginner', 'Beginner'), ('Intermediate', 'Intermediate'), ('Advanced', 'Advanced')],
        default='Beginner'
    )

    def __str__(self):
        return f"{self.title} - {self.artist}"

class UserSong(models.Model):
    """
    Tracks a user's progress, completion, and statistics for a specific song.
    """

    user_profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='user_profile')
    song = models.ForeignKey(Song, on_delete=models.CASCADE, related_name='user_song')
    num_listens = models.IntegerField(default=0)
    num_lyric_challenges_completed = models.IntegerField(default=0)
    mastery_lvl = models.IntegerField(default=0)

    def __str__(self):
        return f"{self.user_profile} - {self.song}"

########################
# Playlist models
########################

class Playlist(models.Model):
    """
    Represents a collection of learning tracks curated for a user.

    Fields:
        user_profile: Owner profile of the playlist.
        playlist_name: Name of the playlist.
        language: Core target learning language.
        genre: Major musical genre representing the selection.
        description: Description details.
        last_date_played: Calendar date when tracks were last listened.
        num_days_listened: Total distinct days listened.
        num_song_listens: Aggregate track listens count.
        proficiency_level: Difficulty level association.
    """
    user_profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='playlists')
    playlist_name = models.CharField(max_length=200)
    language = models.ForeignKey(Language, on_delete=models.CASCADE, related_name='playlists')
    genre = models.ForeignKey(Genre, null=True, on_delete=models.SET_NULL, blank=True, related_name='playlist')
    description = models.TextField(blank=True)
    last_date_played = models.DateField(null=True, blank=True, default=None)
    num_days_listened = models.IntegerField(default=0)
    num_song_listens = models.IntegerField(default=0)
    created_date = models.DateField(auto_now_add=True)
    proficiency_level = models.CharField(
        max_length=20,
        choices=[('Beginner', 'Beginner'), ('Intermediate', 'Intermediate'), ('Advanced', 'Advanced')],
        default='Beginner'
    )

    def __str__(self):
        return self.playlist_name

class PlaylistSong(models.Model):
    """
    Links a specific song track to a Playlist record (many-to-many helper).
    """
    playlist = models.ForeignKey(Playlist, on_delete=models.CASCADE, related_name='playlist_song')
    song = models.ForeignKey(Song, on_delete=models.CASCADE, related_name='playlists_contained_in')

    def __str__(self):
        return f"{self.playlist} - {self.song}"

from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth.models import User
from .models import UserProfile, UserActivity, Language
import random

@receiver(post_save, sender=User)
def build_new_user_starter_pack(sender, instance, created, **kwargs):
    """
    Django post-save signal receiver triggered upon new User creation.

    Purpose:
        Automatically provisions a 'Welcome to SongLingo!' playlist, populates it
        with a random sample of 5 beginner difficulty songs, and links the songs
        to the user's progress.

    Inputs:
        sender (Model): The model class sending the signal (User).
        instance (User): The actual User instance being saved.
        created (bool): Indicates if a new record was created in the DB.
        **kwargs: Extensible signal keyword arguments.

    Outputs:
        None.

    Side Effects:
        - Database mutation: Creates `UserProfile`, `Playlist`, `PlaylistSong`, and `UserSong` records.
        - Prints traceback warnings to stdout in case of generation failure.
    """
    if created:
        try:
            # 1. Safely grab or create the UserProfile for this new user
            profile, _ = UserProfile.objects.get_or_create(
                user=instance,
                defaults={'first_name': instance.username}
            )

            # 2. Safely grab or create a default language (assuming Spanish for now!)
            # Adjust 'Spanish' if your Language model uses language codes like 'es' instead
            default_language, _ = Language.objects.get_or_create(language_name='Spanish')

            # 3. Create the playlist using your exact model field names
            welcome_playlist = Playlist.objects.create(
                user_profile=profile, 
                playlist_name="Welcome to SongLingo!",
                language=default_language,
                description="A sample platter of Jams in Spanish to whet your taste buds"
            )

            # 4. Attach the Beginner songs
            beginner_songs = list(Song.objects.filter(proficiency_level="Beginner"))
            
            if beginner_songs:
                starter_selection = random.sample(beginner_songs, min(len(beginner_songs), 5))
                
                # We loop through the random songs and create the "bridge" link
                for song in starter_selection:
                    PlaylistSong.objects.get_or_create(
                        playlist=welcome_playlist,
                        song=song
                    )
                    UserSong.objects.create(
                        user_profile=profile,
                        song=song
                    )
                
        except Exception as e:
            # This ensures if anything fails, it prints to Docker logs but DOES NOT block the user from signing up
            print(f"CRITICAL: Could not generate starter pack for {instance.username}: {e}")

class SpotifyCredentials(models.Model):
    """
    Stores Spotify API OAuth access and refresh credentials securely.

    Fields:
        user: Reference to the standard auth.User.
        spotify_id: User's explicit Spotify ID.
        access_token: Encoded authorization bearer token.
        refresh_token: Token used to request renewed access tokens.
        expires_at: DateTime timestamp indicating token expiration.
    """
    # Links directly to Django's built-in User system
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='spotify_creds')
    
    spotify_id = models.CharField(max_length=150, null=True, blank=True)
    access_token = models.TextField()
    refresh_token = models.TextField()
    expires_at = models.DateTimeField()

    def __str__(self):
        return f"Spotify Vault - {self.user.username}"