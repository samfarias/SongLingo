from django.contrib import admin
# from .models import UserProfile, Song, Vocabulary, UserProgress
from .models import (
    Language, Genre, UserProfile, GenreSelection, UserActivity, DaysActive,
    Word, UserWord, Song, UserSong, Playlist, PlaylistSong
)

class LanguageAdmin(admin.ModelAdmin):
  readonly_fields = ['id']

class GenreAdmin(admin.ModelAdmin):
  readonly_fields = ['id']

class UserProfileAdmin(admin.ModelAdmin):
  readonly_fields = ['id']

class GenreSelectionAdmin(admin.ModelAdmin):
  readonly_fields = ['id']

class UserActivityAdmin(admin.ModelAdmin):
  readonly_fields = ['id']

class DaysActiveAdmin(admin.ModelAdmin):
  readonly_fields = ['id']

class WordAdmin(admin.ModelAdmin):
  readonly_fields = ['id']

class UserWordAdmin(admin.ModelAdmin):
  readonly_fields = ['id']

class SongAdmin(admin.ModelAdmin):
  readonly_fields = ['id']

class UserSongAdmin(admin.ModelAdmin):
  readonly_fields = ['id']

class PlaylistAdmin(admin.ModelAdmin):
  readonly_fields = ['id']

class PlaylistSongAdmin(admin.ModelAdmin):
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
