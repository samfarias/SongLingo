from django.urls import path
from .views import HomeStatusView, getSongs, createSong

urlpatterns = [
    path('home/status/', HomeStatusView.as_view(), name='home-status'),
    path('songs/', getSongs, name='get-songs'),
    path('songs/create/', createSong, name='create-song')
]