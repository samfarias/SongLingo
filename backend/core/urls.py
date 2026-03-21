from django.urls import path
from .views import HomeScreenView, WordsLearnedView, SongsListenedView, getSongs, createSong

urlpatterns = [
    path('home/', HomeScreenView.as_view(), name='home'),
    path('songs/', getSongs, name='get-songs'),
    path('songs/create/', createSong, name='create-song'),
    path('words-learned/', WordsLearnedView.as_view(), name='words-learned'),
    path('songs-listened/', SongsListenedView.as_view(), name='songs-listened')
]