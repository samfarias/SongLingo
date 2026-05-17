from django.urls import path
from .views import (
    HomeScreenView, WordsLearnedView, SongsListenedView, UserActivityView,
    SinglePlaylistView, PlaylistCollectionView, updateUserWordNumPracticesCompleted,
    updateUserSongProgress, getWordCardExercise, getCompleteTheLyricExercise,
    getLyricMatchExercise, get_pronunciation, CustomLoginView, RegisterView, 
    GenerateWeeklyDropView, UpdateProfileView, generate_weekly_playlist
)
from . import views
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    # --- DASHBOARD & ACTIVITY ---
    path('home/', HomeScreenView.as_view(), name='home'),
    path('words-learned/', WordsLearnedView.as_view(), name='words-learned'),
    path('songs-listened/', SongsListenedView.as_view(), name='songs-listened'),
    path('user-activity/', UserActivityView.as_view(), name='user-activity'),
    
    # --- PLAYLISTS ---
    path('playlist/', SinglePlaylistView.as_view(), name='playlist'),
    path('playlist-collection/', PlaylistCollectionView.as_view(), name='playlist-collection'),
    path('generate-drop/', GenerateWeeklyDropView.as_view(), name='generate-drop'), 
    path('playlists/generate/', generate_weekly_playlist, name='generate-playlist'),
    
    # --- EXERCISES ---
    path('word-card-exercise/', getWordCardExercise, name='word-cards'),
    path('complete-the-lyric-exercise/', getCompleteTheLyricExercise, name='complete-the-lyric-exercise'),
    path('lyric-match-exercise/', getLyricMatchExercise, name='lyric-match-exercise'),
    path('pronunciation/<str:word>/', views.get_pronunciation, name='get_pronunciation'),
    path('word-practices-completed/', updateUserWordNumPracticesCompleted, name='word-practices-completed'),
    path('user-song-progress/', updateUserSongProgress, name='user-song-progress'),
    
    # --- AUTH & PROFILES ---
    path('login/', CustomLoginView.as_view(), name='login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('register/', RegisterView.as_view(), name='register'), 
    path('update-profile/', UpdateProfileView.as_view(), name='update-profile'),
]