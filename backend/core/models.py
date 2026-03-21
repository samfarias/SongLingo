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
    # # Links this profile to the built-in Django Auth system
    # user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')

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
    user_profile_id = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='genre_selections')
    genre = models.ForeignKey(Genre, on_delete=models.CASCADE, related_name='genre_selections')

    def __str__(self):
        return f"{self.user_profile_id} - {self.genre}"


class UserActivity(models.Model):
    user_profile_id = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='activities')
    current_streak = models.IntegerField(default=0)
    longest_streak = models.IntegerField(default=0)

    def __str__(self):
        return f"Activity for {self.user_profile_id}"


class DaysActive(models.Model):
    user_profile_id = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='days_active')
    date = models.DateField()

    def __str__(self):
        return f"{self.user_profile_id} active on {self.date}"

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

class UserWords(models.Model):
    user_profile_id = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='user_words')
    word = models.ForeignKey(Word, on_delete=models.CASCADE, related_name='user_words')
    num_listens = models.IntegerField(default=0)
    num_practices_completed = models.IntegerField(default=0)
    mastery_lvl = models.IntegerField(default=0)

    def __str__(self):
        return f"{self.user_profile_id} - {self.word}"

########################
# Song models
########################

class Song(models.Model):
    title = models.CharField(max_length=200)
    artist = models.CharField(max_length=200)
    language = models.ForeignKey(Language, null=True, on_delete=models.CASCADE, related_name='song')
    primary_genre = models.ForeignKey(Genre, null=True, on_delete=models.SET_NULL, related_name='song')
    spotify_preview_url = models.URLField(blank=True, null=True, help_text="Direct link to  audio clip")
    lyrics = models.TextField(blank=True)
    proficiency_level = models.CharField(
        max_length=20, 
        choices=[('Beginner', 'Beginner'), ('Intermediate', 'Intermediate'), ('Advanced', 'Advanced')],
        default='Beginner'
    )

    def __str__(self):
        return f"{self.title} - {self.artist}"

class SongGenres(models.Model):
    song = models.ForeignKey(Song, on_delete=models.CASCADE, related_name='song_genres')
    genre = models.ForeignKey(Genre, on_delete=models.CASCADE, related_name='song_entries')

    def __str__(self):
        return f"{self.song} - {self.genre}"

class UserSongs(models.Model):
    user_profile_id = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='user_songs')
    song = models.ForeignKey(Song, on_delete=models.CASCADE, related_name='user_progress')
    num_listens = models.IntegerField(default=0)
    num_lyric_challenges_completed = models.IntegerField(default=0)
    mastery_lvl = models.IntegerField(default=0)

    def __str__(self):
        return f"{self.user_profile_id} - {self.song}"

########################
# Playlist models
########################

class Playlist(models.Model):
    user_profile_id = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='playlists')
    playlist_name = models.CharField(max_length=200)
    language = models.ForeignKey(Language, on_delete=models.CASCADE, related_name='playlists')
    description = models.TextField(blank=True)
    num_listens = models.IntegerField(default=0)
    num_song_listens = models.IntegerField(default=0)
    creation_date = models.DateField(auto_now_add=True)
    proficiency_level = models.CharField(
        max_length=20, 
        choices=[('Beginner', 'Beginner'), ('Intermediate', 'Intermediate'), ('Advanced', 'Advanced')],
        default='Beginner'
    )

    def __str__(self):
        return self.playlist_name

class PlaylistSongs(models.Model):
    playlist = models.ForeignKey(Playlist, on_delete=models.CASCADE, related_name='playlist_songs')
    song = models.ForeignKey(Song, on_delete=models.CASCADE, related_name='playlists_contained_in')

    def __str__(self):
        return f"{self.playlist} - {self.song}"

class PlaylistGenres(models.Model):
    playlist = models.ForeignKey(Playlist, on_delete=models.CASCADE, related_name='playlist_genres')
    genre = models.ForeignKey(Genre, on_delete=models.CASCADE, related_name='playlists_featuring')

    def __str__(self):
        return f"{self.playlist} - {self.genre}"

class PlaylistDaysListened(models.Model):
    playlist = models.ForeignKey(Playlist, on_delete=models.CASCADE, related_name='days_listened')
    date = models.DateField()

    def __str__(self):
        return f"{self.playlist} listened on {self.date}"