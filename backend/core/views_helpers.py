from datetime import date
from django.db.models import F
from rest_framework.response import Response
from rest_framework import status
from .models import (
    DaysActive, UserActivity, Playlist
)


# increments user's current_streak, longest_streak (if applicable), and adds a DaysActive record for this day
def updateUserActivity(user_id: int):
    last_activity = DaysActive.objects.filter(user_profile_id=user_id).order_by('-date').first()
    if last_activity and last_activity.date == date.today():
        return
    
    try:
        user_activity = UserActivity.objects.get(user_profile_id=user_id)
        DaysActive.objects.create( # create new Days_Active record
            user_profile_id=user_id,
            date=date.today()
        )
        streak_update_args = { "current_streak": F('current_streak') + 1 } # update streak
        if user_activity.current_streak == user_activity.longest_streak:
            streak_update_args["longest_streak"] = F('longest_streak') + 1

        rows_updated = UserActivity.objects.filter(user_profile_id=user_id).update(**streak_update_args)

    except UserActivity.DoesNotExist:
        print(f"error: Failed to update user activity for user_id {user_id}. User_Activity with this user_id does not exist")


# increments (+1) Playlist.num_song_listens. Updates last_date_played and num_days_played if it's a new day
def updateUserPlaylistNumSongListens(playlist_id: int) -> int:
    try:
        playlist = Playlist.objects.get(pk=playlist_id)
        update_args = {
            "num_song_listens": F('num_song_listens') + 1
        }
        if playlist.last_date_played != date.today():
            update_args['last_date_played'] = date.today()
            update_args['num_days_listened'] = F('num_days_listened') + 1

        rows_updated = Playlist.objects.filter(pk=playlist_id).update(**update_args)
        return rows_updated
    except Playlist.DoesNotExist:
        return 0