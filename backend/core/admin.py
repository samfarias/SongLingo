from django.contrib import admin
from .models import UserProfile, Song, Vocabulary, UserProgress

# Register your models here.
admin.site.register(UserProfile)
admin.site.register(Song)
admin.site.register(Vocabulary)
admin.site.register(UserProgress)