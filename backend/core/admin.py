from django.contrib import admin
# from .models import UserProfile, Song, Vocabulary, UserProgress
from .models import (
    Language, Genre, UserProfile, GenreSelection, UserActivity, DaysActive,
    Word, UserWords, Song, UserSongs, Playlist, PlaylistSongs, PlaylistDaysListened
)

# Register your models here.
admin.site.register(Language)
admin.site.register(Genre)
admin.site.register(UserProfile)
admin.site.register(GenreSelection)
admin.site.register(UserActivity)
admin.site.register(DaysActive)
admin.site.register(Word)
admin.site.register(UserWords)
admin.site.register(Song)
admin.site.register(UserSongs)
admin.site.register(Playlist)
admin.site.register(PlaylistSongs)
admin.site.register(PlaylistDaysListened)


# # Register your models here.
# # admin.site.register(UserProfile)
# # admin.site.register(Song)
# # admin.site.register(Vocabulary)
# # admin.site.register(UserProgress)
