from django.db import models
from django.contrib.auth.models import User
from datetime import date

# 1. The User Profile (Handles Onboarding & Streaks)
class UserProfile(models.Model):
    # Links this profile to the built-in Django Auth system
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    
    # Onboarding Selections
    target_language = models.CharField(max_length=50, default="Spanish")
    proficiency_level = models.CharField(
        max_length=20, 
        choices=[('Beginner', 'Beginner'), ('Intermediate', 'Intermediate'), ('Advanced', 'Advanced')],
        default='Beginner'
    )
    # Storing comma-separated genres (e.g., "Pop,Rock,Indie") to keep it simple
    favorite_genres = models.CharField(max_length=200, blank=True)
    
    # Gamification
    current_streak = models.IntegerField(default=0)
    last_login_date = models.DateField(null=True, blank=True)

    def __str__(self):
        return f"{self.user.username}'s Profile"

# 2. The Song Model (Spotify & Genre)
class Song(models.Model):
    title = models.CharField(max_length=200)
    artist = models.CharField(max_length=200)
    genre = models.CharField(max_length=100, blank=True)
    
    # Starting spotify preview URL (for a short MP3 clip)
    spotify_preview_url = models.URLField(blank=True, null=True, help_text="Direct link to  audio clip")
    
    lyrics = models.TextField()
    difficulty_level = models.IntegerField(choices=[(i, i) for i in range(1, 6)], default=1)

    def __str__(self):
        return f"{self.title} - {self.artist}"

# 3. Vocabulary Model (Adding wrong answers for games, so the front end knows what's correct)
class Vocabulary(models.Model):
    word_text = models.CharField(max_length=100)
    translation = models.CharField(max_length=100)
    root_form = models.CharField(max_length=100, blank=True, null=True)
    
    # Distractors for the "Word Cards" Multiple Choice Game (aka wrong answers)
    distractor_1 = models.CharField(max_length=100, blank=True, help_text="Wrong answer 1")
    distractor_2 = models.CharField(max_length=100, blank=True, help_text="Wrong answer 2")
    distractor_3 = models.CharField(max_length=100, blank=True, help_text="Wrong answer 3")

    related_songs = models.ManyToManyField(Song, related_name='vocabulary')

    def __str__(self):
        return f"{self.word_text} ({self.translation})"

# 4. The Progress Tracker (Remains mostly the same)
class UserProgress(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    vocabulary = models.ForeignKey(Vocabulary, on_delete=models.CASCADE)
    
    # 0 = Brand new to it, 5 = Mastered it
    knowledge_level = models.IntegerField(default=0)
    last_practiced = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ('user', 'vocabulary')
        
    def __str__(self):
        return f"{self.user.username} - {self.vocabulary.word_text} (Lvl {self.knowledge_level})"