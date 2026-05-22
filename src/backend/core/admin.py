"""
Module: admin
Description: Configures and registers models for the Django administration panel,
             ensuring ID fields are read-only to prevent accidental modification.
"""
from django.contrib import admin
# from .models import UserProfile, Song, Vocabulary, UserProgress
from .models import (
    Language, Genre, UserProfile, GenreSelection, UserActivity, DaysActive,
    Word, UserWord, Song, UserSong, Playlist, PlaylistSong
)

class LanguageAdmin(admin.ModelAdmin):
  """
  Admin interface configuration for the Language model.
  Configures 'id' as a read-only field in the admin panel.
  """
  readonly_fields = ['id']

class GenreAdmin(admin.ModelAdmin):
  """
  Admin interface configuration for the Genre model.
  Configures 'id' as a read-only field in the admin panel.
  """
  readonly_fields = ['id']

class UserProfileAdmin(admin.ModelAdmin):
  """
  Admin interface configuration for the UserProfile model.
  Configures 'id' as a read-only field in the admin panel.
  """
  readonly_fields = ['id']

class GenreSelectionAdmin(admin.ModelAdmin):
  """
  Admin interface configuration for the GenreSelection model.
  Configures 'id' as a read-only field in the admin panel.
  """
  readonly_fields = ['id']

class UserActivityAdmin(admin.ModelAdmin):
  """
  Admin interface configuration for the UserActivity model.
  Configures 'id' as a read-only field in the admin panel.
  """
  readonly_fields = ['id']

class DaysActiveAdmin(admin.ModelAdmin):
  """
  Admin interface configuration for the DaysActive model.
  Configures 'id' as a read-only field in the admin panel.
  """
  readonly_fields = ['id']

class WordAdmin(admin.ModelAdmin):
  """
  Admin interface configuration for the Word model.
  Configures 'id' as a read-only field in the admin panel.
  """
  readonly_fields = ['id']

class UserWordAdmin(admin.ModelAdmin):
  """
  Admin interface configuration for the UserWord model.
  Configures 'id' as a read-only field in the admin panel.
  """
  readonly_fields = ['id']

class SongAdmin(admin.ModelAdmin):
  """
  Admin interface configuration for the Song model.
  Configures 'id' as a read-only field in the admin panel.
  """
  readonly_fields = ['id']

class UserSongAdmin(admin.ModelAdmin):
  """
  Admin interface configuration for the UserSong model.
  Configures 'id' as a read-only field in the admin panel.
  """
  readonly_fields = ['id']

class PlaylistAdmin(admin.ModelAdmin):
  """
  Admin interface configuration for the Playlist model.
  Configures 'id' as a read-only field in the admin panel.
  """
  readonly_fields = ['id']

class PlaylistSongAdmin(admin.ModelAdmin):
  """
  Admin interface configuration for the PlaylistSong model.
  Configures 'id' as a read-only field in the admin panel.
  """
  readonly_fields = ['id']


# Register your models here.
admin.site.register(Language, LanguageAdmin)
admin.site.register(Genre, GenreAdmin)
admin.site.register(UserProfile, UserProfileAdmin)
admin.site.register(GenreSelection, GenreSelectionAdmin)
admin.site.register(UserActivity, UserActivityAdmin)
admin.site.register(DaysActive, DaysActiveAdmin)
admin.site.register(Word, WordAdmin)
admin.site.register(UserWord, UserWordAdmin)
admin.site.register(Song, SongAdmin)
admin.site.register(UserSong, UserSongAdmin)
admin.site.register(Playlist, PlaylistAdmin)
admin.site.register(PlaylistSong, PlaylistSongAdmin)

