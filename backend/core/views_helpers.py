import os
import requests
import base64
from datetime import date
from dotenv import load_dotenv
from django.db.models import F
from rest_framework.response import Response
from rest_framework import status
from .models import (
    DaysActive, UserActivity, Playlist
)

load_dotenv()
#grab API keys
SPOTIFY_CLIENT_ID = os.getenv('SPOTIFY_CLIENT_ID')
SPOTIFY_CLIENT_SECRET = os.getenv('SPOTIFY_CLIENT_SECRET')
GENIUS_ACCESS_TOKEN = os.getenv('GENIUS_ACCESS_TOKEN')

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
    
#--> External API helper functions <--#

def get_spotify_access_token():
    """Authenticates with Spotify and returns a temporary access token."""
    # spotify requires your ID and secret to be combined and Base64 encoded
    auth_string = f"{SPOTIFY_CLIENT_ID}:{SPOTIFY_CLIENT_SECRET}"
    auth_bytes = auth_string.encode("utf-8")
    auth_base64 = str(base64.b64encode(auth_bytes), "utf-8")

    # set up the request headers and URL
    url = "https://accounts.spotify.com/api/token"
    headers = {
        "Authorization": "Basic " + auth_base64,
        "Content-Type": "application/x-www-form-urlencoded"
    }
    
    # specifying to spotify we just want generic app-level access (so no login required)
    data = {
        "grant_type": "client_credentials"
    }

    # make the POST request to get the token
    response = requests.post(url, headers=headers, data=data)
    
    if response.status_code == 200:
        json_data = response.json()
        return json_data["access_token"]
    else:
        print(f"Error fetching Spotify token: {response.status_code}")
        print(response.json())
        return None
    
def search_spotify_track(song_title, artist_name, token):
    """Searches Spotify for a specific track and returns its data."""
    url = "https://api.spotify.com/v1/search"
    
    headers = {
        "Authorization": f"Bearer {token}"
    }
    
    # query format per spotify docs
    query = f"track:{song_title} artist:{artist_name}"
    
    params = {
        "q": query,
        "type": "track",
        "limit": 1  # only the top result
    }
    
    response = requests.get(url, headers=headers, params=params)
    
    if response.status_code == 200:
        data = response.json()
        tracks = data.get("tracks", {}).get("items", [])
        
        if tracks:
            # grab very first track
            track = tracks[0]
            return {
                "title": track["name"],
                "artist": track["artists"][0]["name"],
                "spotify_id": track["id"],
                "preview_url": track.get("preview_url")
            }
        else:
            print(f"No results found for {song_title} by {artist_name}")
            return None
    else:
        print(f"Error searching Spotify: {response.status_code}")
        return None