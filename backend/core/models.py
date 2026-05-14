from django.db import models
from django.contrib.auth.models import User
from datetime import date


########################
# Supporting models
########################

class Language(models.Model):
    language_name = models.CharField(max_length=100)

    def __str__(self):
        return self.language_name

class Genre(models.Model):
    genre_name = models.CharField(max_length=100)

    def __str__(self):
        return self.genre_name

########################
# User models
########################

class UserProfile(models.Model):
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
    user_profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='genre_selections')
    genre = models.ForeignKey(Genre, on_delete=models.CASCADE, related_name='genre_selections')

    def __str__(self):
        return f"{self.user_profile} - {self.genre}"


class UserActivity(models.Model):
    user_profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='activities')
    current_streak = models.IntegerField(default=0)
    longest_streak = models.IntegerField(default=0)

    def __str__(self):
        return f"Activity for {self.user_profile}"


class DaysActive(models.Model):
    user_profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='days_active')
    date = models.DateField()

    def __str__(self):
        return f"{self.user_profile} active on {self.date}"

########################
# Word models
########################

class Word(models.Model):
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
    title = models.CharField(max_length=200)
    artist = models.CharField(max_length=200)
    spotify_id = models.CharField(max_length=100, unique=True, null=True, blank=True)
    language = models.ForeignKey(Language, null=True, on_delete=models.CASCADE, related_name='song')
    genre = models.ForeignKey(Genre, null=True, on_delete=models.SET_NULL, related_name='song')
    vocabulary_json = models.JSONField(default=list, blank=True)
    spotify_preview_url = models.URLField(blank=True, null=True, help_text="Direct link to  audio clip")
    lyrics = models.TextField(blank=True)
    proficiency_level = models.CharField(
        max_length=20,
        choices=[('Beginner', 'Beginner'), ('Intermediate', 'Intermediate'), ('Advanced', 'Advanced')],
        default='Beginner'
    )

    def __str__(self):
        return f"{self.title} - {self.artist}"

class UserSong(models.Model):

    user_profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='user_song')
    song = models.ForeignKey(Song, on_delete=models.CASCADE, related_name='user_progress')
    num_listens = models.IntegerField(default=0)
    num_lyric_challenges_completed = models.IntegerField(default=0)
    mastery_lvl = models.IntegerField(default=0)

    def __str__(self):
        return f"{self.user_profile} - {self.song}"

########################
# Playlist models
########################

class Playlist(models.Model):
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
    playlist = models.ForeignKey(Playlist, on_delete=models.CASCADE, related_name='playlist_song')
    song = models.ForeignKey(Song, on_delete=models.CASCADE, related_name='playlists_contained_in')

    def __str__(self):
        return f"{self.playlist} - {self.song}"

from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth.models import User
from .models import UserProfile, UserActivity, Language

# This listens for any time a new User is created
@receiver(post_save, sender=User)
def create_user_data(sender, instance, created, **kwargs):
    if created:
        spanish_lang, _ = Language.objects.get_or_create(language_name="Spanish")
        profile = UserProfile.objects.create(
        user=instance,
        first_name=instance.username,
        last_name="",
        target_language=spanish_lang,
        proficiency_level="Beginner"
        )

        #  instantiate the Streak by linking it to the profile we just created!
        UserActivity.objects.create(
            user_profile=profile,
            current_streak=1,
            longest_streak=1
        )


from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth.models import User
import random

@receiver(post_save, sender=User)
def build_new_user_starter_pack(sender, instance, created, **kwargs):
    if created:
        try:
            # 1. Safely grab or create the UserProfile for this new user
            profile, _ = UserProfile.objects.get_or_create(user=instance)

            # 2. Safely grab or create a default language (assuming Spanish for now!)
            # Adjust 'Spanish' if your Language model uses language codes like 'es' instead
            default_language, _ = Language.objects.get_or_create(name='Spanish')

            # 3. Create the playlist using your exact model field names
            welcome_playlist = Playlist.objects.create(
                user_profile=profile, 
                playlist_name="Welcome to SongLingo! 🎵",
                language=default_language,
                description="A hand-picked starter pack of easy songs to get you practicing immediately."
            )

            # 4. Attach the Beginner songs
            beginner_songs = list(Song.objects.filter(proficiency_level="Beginner"))
            
            if beginner_songs:
                starter_selection = random.sample(beginner_songs, min(len(beginner_songs), 5))
                # Assuming your related_name for songs on the Playlist model is 'songs'
                welcome_playlist.songs.set(starter_selection)
                
        except Exception as e:
            # This ensures if anything fails, it prints to Docker logs but DOES NOT block the user from signing up
            print(f"CRITICAL: Could not generate starter pack for {instance.username}: {e}")