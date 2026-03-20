from django.urls import path
from .views import HomeScreenView, getSongs, createSong

urlpatterns = [
    path('home/', HomeScreenView.as_view(), name='home'),
    path('songs/', getSongs, name='get-songs'),
    path('songs/create/', createSong, name='create-song')
]