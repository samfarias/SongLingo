from django.urls import path
from .views import GenerateWeeklyDropView
from .views import (HomeScreenView, WordsLearnedView, SongsListenedView, UserActivityView,
                    SinglePlaylistView, PlaylistCollectionView, updateUserWordNumPracticesCompleted,
                    updateUserSongProgress, getWordCardExercise, getCompleteTheLyricExercise
)

urlpatterns = [
    path('home/', HomeScreenView.as_view(), name='home'),
    path('words-learned/', WordsLearnedView.as_view(), name='words-learned'),
    path('songs-listened/', SongsListenedView.as_view(), name='songs-listened'),
    path('user-activity/', UserActivityView.as_view(), name='user-activity'),
    path('playlist/', SinglePlaylistView.as_view(), name='playlist'),
    path('playlist-collection/', PlaylistCollectionView.as_view(), name='playlist-collection'),
    path('word-practices-completed', updateUserWordNumPracticesCompleted, name='word-practices-completed'),
    path('user-song-progress', updateUserSongProgress, name='user-song-progress'),
    path('generate-drop/', GenerateWeeklyDropView.as_view(), name='generate-drop')
    path('word-card-exercise', getWordCardExercise, name='word-card-excercise'),
    path('complete-the-lyric-exercise', getCompleteTheLyricExercise, name='complete-the-lyric-exercise')
]