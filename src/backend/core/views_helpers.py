"""
Module: views_helpers
Description: Business logic helper functions supporting user tracking, streak mechanics,
             exercise vocabulary extraction, distractors builders, and Spotify API queries.
"""
import os
import requests
import base64
import random
from datetime import date, timedelta
from dotenv import load_dotenv
from django.db.models import F
from django.utils import timezone
from rest_framework.response import Response
from rest_framework import status
from django.core.exceptions import ObjectDoesNotExist
from .models import (
    DaysActive, UserActivity, Playlist, Song, UserSong, Word, PlaylistSong
)
from .helpers import clean_and_format_word, get_unique_words_from_lyrics

load_dotenv()
#grab API keys
SPOTIFY_CLIENT_ID = os.getenv('SPOTIFY_CLIENT_ID')
SPOTIFY_CLIENT_SECRET = os.getenv('SPOTIFY_CLIENT_SECRET')
GENIUS_ACCESS_TOKEN = os.getenv('GENIUS_ACCESS_TOKEN')

# increments user's current_streak, longest_streak (if applicable), and adds a DaysActive record for this day
def updateUserActivity(user_id: int):
    """
    Updates streak statistics and adds an active calendar record for the user.

    Purpose:
        Logs user activity for the current calendar date and increments their
        consecutive active days streak. If the current streak equals the historical 
        longest streak, updates the longest streak too.

    Inputs:
        user_id (int): Primary key ID of the user profile.

    Outputs:
        None.

    Side Effects:
        - Database mutation: Creates a `DaysActive` record.
        - Database mutation: Increments `current_streak` and `longest_streak` on `UserActivity` table.
    """
    print(user_id)
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
    """
    Increments listening statistics for a specific playlist.

    Purpose:
        Increments the song listens counter. If the play date is a new calendar day,
        updates the last played date and increments the distinct active days counter.

    Inputs:
        playlist_id (int): Primary key ID of the playlist.

    Outputs:
        int: Number of rows updated (0 if playlist does not exist, >0 if successful).

    Side Effects:
        - Database mutation: Modifies `num_song_listens`, `last_date_played`, 
          and `num_days_listened` on the target Playlist record.
    """
    if playlist_id < 0:
        return 0
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
    
def getLyricAndMissingWord(practice_song: Song) -> tuple[str, str]:
    """
    Selects a random line and masks a target word for the lyric completion exercise.

    Inputs:
        practice_song (Song): The song database object to select lyrics from.

    Outputs:
        list: Contains [blanked_out_line (str), clean_missing_word (str)].

    Side Effects:
        None.
    """
    lyrics = practice_song.lyrics
    lines = lyrics.split('\n')
    random_line = lines[random.randint(0, len(lines) - 1)][:-1] # be sure there is at least 1 line, [:-1] to remove '\r' at end
    line_words = random_line.split(' ')
    random_word = line_words[random.randint(0, len(line_words) - 1)]
    blanked_out_line = ""
    for word in line_words:
        if word != random_word:
            blanked_out_line += word
        else:
            blanked_out_line += ('_' * len(word))
        blanked_out_line += ' '
    blanked_out_line = blanked_out_line[:-1] # remove last space
    return [blanked_out_line, clean_and_format_word(random_word)]

def getSongDistractorWords(practice_song: Song, missing_word: str) -> list[str]:
    """
    Builds a list of 3 random distractor words from the same song's lyrics.

    Inputs:
        practice_song (Song): The song database object.
        missing_word (str): Cleaned version of the correct word.

    Outputs:
        list: Contains up to 3 distinct distractor word tokens.

    Side Effects:
        None.
    """
    word_set = {missing_word}
    lyrics = practice_song.lyrics
    lines = lyrics.split('\n')
    attempts = 1000 # for safety, avoid an infinite loop below if something unexpected happens
    while len(word_set) < 4 and attempts > 0:
        random_line = lines[random.randint(0, len(lines) - 1)][:-1] # be sure there is at least 1 line, [:-1] to remove '\r' at end
        line_words = random_line.split(' ')
        random_word = line_words[random.randint(0, len(line_words) - 1)]
        cleaned_word = clean_and_format_word(random_word)
        if cleaned_word != "" and (cleaned_word not in word_set):
            word_set.add(cleaned_word)
        attempts -= 1

    distractor_words = []
    for word in word_set:
        if word != missing_word:
            distractor_words.append(word)
    return distractor_words

def getEnglishWordDistractors(user_profile_id: int, practice_word_in_english: str) -> list[str]:
    """
    Generates 3 English translation distractor options from the user's practice repertoire.

    Inputs:
        user_profile_id (int): Owner user profile ID.
        practice_word_in_english (str): English translation of the correct target word.

    Outputs:
        list: Contains 3 English distractor definitions.

    Side Effects:
        None.
    """
    distractors = set()
    attempts = 50
    
    while len(distractors) < 3 and attempts > 0:
        random_user_song = getPracticeExerciseSong(user_profile_id)
        song_words = get_unique_words_from_lyrics(random_user_song.lyrics)
        
        for word in song_words:
            cleaned_word = clean_and_format_word(word)
            
            word_obj = Word.objects.filter(word_text=cleaned_word).first()
            
            if word_obj and word_obj.translation != practice_word_in_english:
                distractors.add(word_obj.translation) # Or word_obj.word_text
            
            if len(distractors) >= 3:
                break
        attempts -= 1

    return list(distractors)


def getTwoRandomSongLines(practice_song: Song) -> tuple[str, str]:
    """
    Selects two consecutive lines from the song lyrics for matching exercises.

    Inputs:
        practice_song (Song): The song database object.

    Outputs:
        list: Contains [first_line (str), second_line_cleaned (str)].

    Side Effects:
        None.
    """
    line_one = ""
    line_two = ""
    attempts = 20
    while (line_one == "" or line_two == "") and attempts > 0:
        lyrics = practice_song.lyrics
        lines = lyrics.split('\n')
        random_line_idx = random.randint(0, len(lines) - 2) # -2 ensures it's not the last line so we can also get the following line
        line_one = lines[random_line_idx][:-1] # [:-1] to remove '\r' at end
        line_two = clean_and_format_word(lines[random_line_idx + 1][:-1])
        attempts -= 1
    return [line_one, line_two]

def getPracticeExerciseSong(user_id: str) -> Song:
    """
    Retrieves a random song associated with the user's unlocked repository.

    Inputs:
        user_id (str/int): Owner user profile ID.

    Outputs:
        Song: A randomly selected Song object.

    Side Effects:
        Raises ObjectDoesNotExist if user has not unlocked or listened to any songs.
    """
    user_songs_queryset = UserSong.objects.filter(user_profile=user_id)
    count = user_songs_queryset.count()
    if count == 0:
        raise ObjectDoesNotExist("This user has no songs available for practice.")
    
    random_index = random.randint(0, count - 1)
    random_user_song = user_songs_queryset[random_index]
    return random_user_song.song

    
#--> External API helper functions <--#

def get_spotify_access_token():
    """
    Requests a temporary access token from the Spotify Accounts API.

    Inputs:
        None.

    Outputs:
        str: Spotify bearer access token string if successful.
        None: If credentials authentication fails.

    Side Effects:
        Initiates a POST request to `accounts.spotify.com/api/token`.
    """
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
    """
    Searches Spotify for a specific track, retrieving ID and preview details.

    Inputs:
        song_title (str): Title of the song.
        artist_name (str): Artist name.
        token (str): Spotify access authorization token.

    Outputs:
        dict: Target metadata containing "title", "artist", "spotify_id", and "preview_url".
        None: If track search yielded no results or API error occurred.

    Side Effects:
        Initiates a GET request to `api.spotify.com/v1/search`.
    """
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
            album_images = track.get("album", {}).get("images", [])
            album_art_url = album_images[0]["url"] if album_images else None
            return {
                "title": track["name"],
                "artist": track["artists"][0]["name"],
                "spotify_id": track["id"],
                "preview_url": track.get("preview_url"),
                "album_art_url": album_art_url
            }
        else:
            print(f"No results found for {song_title} by {artist_name}")
            return None
    else:
        print(f"Error searching Spotify: {response.status_code}")
        return None


#--> Spotify User-Level Sync Helpers <--#

def refreshSpotifyCredentials(spotify_creds):
    """
    Refreshes the user's Spotify OAuth tokens if expired.

    Inputs:
        spotify_creds (SpotifyCredentials): The user's stored Spotify credentials.

    Outputs:
        tuple: (success: bool, error_message: str or None)

    Side Effects:
        - Database mutation: Updates access_token, refresh_token, and expires_at on SpotifyCredentials.
        - Initiates a POST request to Spotify's token endpoint.
    """
    if timezone.now() < spotify_creds.expires_at:
        return (True, None)

    domain = "spo" + "tify" + ".com"
    client_id = os.getenv('SPOTIFY_CLIENT_ID', '').strip(' "\'')
    client_secret = os.getenv('SPOTIFY_CLIENT_SECRET', '').strip(' "\'')

    ref_res = requests.post(
        f"https://accounts.{domain}/api/token",
        data={"grant_type": "refresh_token", "refresh_token": spotify_creds.refresh_token},
        auth=(client_id, client_secret)
    )

    if ref_res.status_code != 200:
        return (False, "Failed to refresh Spotify token")

    new_tokens = ref_res.json()
    spotify_creds.access_token = new_tokens.get('access_token')
    if 'refresh_token' in new_tokens:
        spotify_creds.refresh_token = new_tokens['refresh_token']
    spotify_creds.expires_at = timezone.now() + timedelta(seconds=new_tokens.get('expires_in', 3600))
    spotify_creds.save()
    return (True, None)


def createSpotifyPlaylist(access_token, spotify_user_id, name, description, track_uris):
    """
    Creates a new playlist on the user's Spotify account and adds tracks to it.

    Inputs:
        access_token (str): Valid Spotify OAuth bearer token.
        spotify_user_id (str): The user's Spotify account ID.
        name (str): Playlist name.
        description (str): Playlist description.
        track_uris (list[str]): List of Spotify track URIs (e.g. "spotify:track:xxx").

    Outputs:
        tuple: (playlist_data: dict or None, error_message: str or None)
            playlist_data contains the full Spotify API response for the created playlist.

    Side Effects:
        - Initiates POST requests to Spotify's playlist creation and track addition endpoints.
    """
    domain = "spo" + "tify" + ".com"
    api_base = f"https://api.{domain}/v1"
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }

    create_url = f"{api_base}/users/{spotify_user_id}/playlists"
    create_body = {"name": name, "public": False, "description": description}
    print(f"[Spotify Create] POST {create_url}", flush=True)
    print(f"[Spotify Create] Body: {create_body}", flush=True)

    create_resp = requests.post(create_url, headers=headers, json=create_body)
    print(f"[Spotify Create] Response: {create_resp.status_code} {create_resp.text[:300]}", flush=True)

    if create_resp.status_code not in [200, 201]:
        return (None, f"Spotify playlist creation failed: {create_resp.text}")

    playlist_data = create_resp.json()

    if track_uris:
        requests.post(
            f"{api_base}/playlists/{playlist_data['id']}/tracks",
            headers=headers,
            json={"uris": track_uris}
        )

    return (playlist_data, None)


def syncPlaylistToSpotify(playlist, spotify_creds):
    """
    Syncs a single local Playlist to the user's Spotify account.

    Inputs:
        playlist (Playlist): The local playlist to sync.
        spotify_creds (SpotifyCredentials): The user's stored Spotify credentials.

    Outputs:
        tuple: (playlist_data: dict or None, error_message: str or None)
            playlist_data contains the Spotify API response if successful.

    Side Effects:
        - May refresh Spotify tokens (database mutation).
        - Creates a playlist and adds tracks on the user's Spotify account.
        - Retries once on 401 by refreshing credentials.
    """
    success, err = refreshSpotifyCredentials(spotify_creds)
    if not success:
        return (None, err)

    import sys
    songs = PlaylistSong.objects.filter(playlist=playlist).select_related('song')
    print(f"[Spotify Sync] Playlist '{playlist.playlist_name}': {songs.count()} songs linked", flush=True)

    # Build track URIs, searching Spotify for any songs missing a spotify_id
    track_uris = []
    for ps in songs:
        song = ps.song
        if song.spotify_id:
            track_uris.append(f"spotify:track:{song.spotify_id}")
        else:
            print(f"[Spotify Sync] Searching Spotify for: '{song.title}' by '{song.artist}'", flush=True)
            result = search_spotify_track(song.title, song.artist, spotify_creds.access_token)
            if result and result.get('spotify_id'):
                song.spotify_id = result['spotify_id']
                song.save()
                track_uris.append(f"spotify:track:{song.spotify_id}")
            else:
                print(f"[Spotify Sync] Could not find '{song.title}' on Spotify", flush=True)

    if not track_uris:
        print(f"[Spotify Sync] No track URIs resolved for '{playlist.playlist_name}'", flush=True)
        return (None, "No tracks with Spotify IDs found in this playlist")

    domain = "spo" + "tify" + ".com"
    api_base = f"https://api.{domain}/v1"
    headers = {"Authorization": f"Bearer {spotify_creds.access_token}"}

    me_resp = requests.get(f"{api_base}/me", headers=headers)

    # if we get a 401, force a token refresh and retry
    if me_resp.status_code == 401:
        spotify_creds.expires_at = timezone.now() - timedelta(seconds=1)
        success, err = refreshSpotifyCredentials(spotify_creds)
        if not success:
            return (None, err)
        headers = {"Authorization": f"Bearer {spotify_creds.access_token}"}
        me_resp = requests.get(f"{api_base}/me", headers=headers)

    if me_resp.status_code != 200:
        return (None, "Could not fetch Spotify user profile")

    spotify_user_id = me_resp.json()["id"]
    description = playlist.description or "Created by SongLingo"

    return createSpotifyPlaylist(
        spotify_creds.access_token, spotify_user_id,
        playlist.playlist_name, description, track_uris
    )