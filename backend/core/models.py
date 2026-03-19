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
    first_name = models.CharField(max_length=100, null=True)
    last_name = models.CharField(max_length=100, null=True)
    target_language = models.ForeignKey(Language, on_delete=models.SET_NULL, null=True, related_name='users')
    proficiency_level = models.IntegerField()

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
    foreign_word = models.CharField(max_length=200)
    translation = models.CharField(max_length=200)
    pronunciation = models.CharField(max_length=200, blank=True)
    definition = models.TextField(blank=True)
    proficiency_level = models.IntegerField(default=1)
    lexical_category = models.CharField(max_length=100, blank=True) # Noun, verb, phrase, etc.

    def __str__(self):
        return f"{self.foreign_word} ({self.translation})"

class UserWords(models.Model):
    user_profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='user_words')
    word = models.ForeignKey(Word, on_delete=models.CASCADE, related_name='user_words')
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
    language = models.ForeignKey(Language, null=True, on_delete=models.CASCADE, related_name='songs')
    proficiency_level = models.IntegerField(default=1)
    clip_preview_url = models.URLField(blank=True, null=True)
    lyrics = models.TextField(blank=True)

    def __str__(self):
        return f"{self.title} - {self.artist}"

class SongGenres(models.Model):
    song = models.ForeignKey(Song, on_delete=models.CASCADE, related_name='song_genres')
    genre = models.ForeignKey(Genre, on_delete=models.CASCADE, related_name='song_entries')

    def __str__(self):
        return f"{self.song} - {self.genre}"

class UserSongs(models.Model):
    user_profile = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='user_songs')
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
    description = models.TextField(blank=True)
    proficiency_level = models.IntegerField(default=1)
    num_listens = models.IntegerField(default=0)
    num_song_listens = models.IntegerField(default=0)
    creation_date = models.DateField(auto_now_add=True)

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



# # 1. The User Profile (Handles Onboarding & Streaks)
# class UserProfile(models.Model):
#     # Links this profile to the built-in Django Auth system
#     user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    
#     # Onboarding Selections
#     target_language = models.CharField(max_length=50, default="Spanish")
#     proficiency_level = models.CharField(
#         max_length=20, 
#         choices=[('Beginner', 'Beginner'), ('Intermediate', 'Intermediate'), ('Advanced', 'Advanced')],
#         default='Beginner'
#     )
#     # Storing comma-separated genres (e.g., "Pop,Rock,Indie") to keep it simple
#     favorite_genres = models.CharField(max_length=200, blank=True)
    
#     # Gamification
#     current_streak = models.IntegerField(default=0)
#     last_login_date = models.DateField(null=True, blank=True)

#     def __str__(self):
#         return f"{self.user.username}'s Profile"

# 2. The Song Model (Spotify & Genre)
# class Song(models.Model):
#     title = models.CharField(max_length=200)
#     artist = models.CharField(max_length=200)
#     genre = models.CharField(max_length=100, blank=True)
    
#     # Starting spotify preview URL (for a short MP3 clip)
#     spotify_preview_url = models.URLField(blank=True, null=True, help_text="Direct link to  audio clip")
    
#     lyrics = models.TextField()
#     difficulty_level = models.IntegerField(choices=[(i, i) for i in range(1, 6)], default=1)

#     def __str__(self):
#         return f"{self.title} - {self.artist}"

# # 3. Vocabulary Model (Adding wrong answers for games, so the front end knows what's correct)
# class Vocabulary(models.Model):
#     word_text = models.CharField(max_length=100)
#     translation = models.CharField(max_length=100)
#     root_form = models.CharField(max_length=100, blank=True, null=True)
    
#     # Distractors for the "Word Cards" Multiple Choice Game (aka wrong answers)
#     distractor_1 = models.CharField(max_length=100, blank=True, help_text="Wrong answer 1")
#     distractor_2 = models.CharField(max_length=100, blank=True, help_text="Wrong answer 2")
#     distractor_3 = models.CharField(max_length=100, blank=True, help_text="Wrong answer 3")

#     related_songs = models.ManyToManyField(Song, related_name='vocabulary')

#     def __str__(self):
#         return f"{self.word_text} ({self.translation})"

# # 4. The Progress Tracker (Remains mostly the same)
# class UserProgress(models.Model):
#     user = models.ForeignKey(User, on_delete=models.CASCADE)
#     vocabulary = models.ForeignKey(Vocabulary, on_delete=models.CASCADE)
    
#     # 0 = Brand new to it, 5 = Mastered it
#     knowledge_level = models.IntegerField(default=0)
#     last_practiced = models.DateTimeField(auto_now=True)

#     class Meta:
#         unique_together = ('user', 'vocabulary')
        
#     def __str__(self):
#         return f"{self.user.username} - {self.vocabulary.word_text} (Lvl {self.knowledge_level})"

