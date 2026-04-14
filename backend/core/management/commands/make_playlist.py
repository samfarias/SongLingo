import os
import requests
from django.core.management.base import BaseCommand
from dotenv import load_dotenv, find_dotenv
import spotipy
from spotipy.oauth2 import SpotifyOAuth

# import your existing helper function
from core.views_helpers import search_spotify_track

load_dotenv(find_dotenv())

class Command(BaseCommand):
    help = 'Creates a playlist and populates it with our curated weekly songs'

    def handle(self, *args, **kwargs):
        client_id = os.getenv('SPOTIFY_CLIENT_ID')
        client_secret = os.getenv('SPOTIFY_CLIENT_SECRET')
        redirect_uri = os.getenv('SPOTIPY_REDIRECT_URI')

        # nuke the cache to guarantee 100% fresh permissions
        if os.path.exists("spotify_token.txt"):
            os.remove("spotify_token.txt")

        self.stdout.write("Connecting to Spotify via OAuth...")
        scope = "playlist-modify-public playlist-modify-private playlist-read-private user-read-email"
        
        try:
            auth_manager = SpotifyOAuth(
                client_id=client_id,
                client_secret=client_secret,
                redirect_uri=redirect_uri,
                scope=scope,
                show_dialog=True,  
                cache_path="spotify_token.txt"
            )
            sp = spotipy.Spotify(auth_manager=auth_manager)
            
            # --- THE MISSING LINES I ACCIDENTALLY DELETED ---
            # this forces the browser to open and generates the token
            user_info = sp.current_user()
            self.stdout.write(f"Authenticated as: {user_info['display_name']}")
            # ------------------------------------------------
            
            access_token = auth_manager.get_cached_token()['access_token']
            
            self.stdout.write("Creating weekly drop playlist...")
            
            # 1. create the playlist via the /me endpoint
            url_create = "https://api.spotify.com/v1/me/playlists"
            headers = {
                "Authorization": f"Bearer {access_token}",
                "Content-Type": "application/json"
            }
            data_create = {
                "name": "SongLingo Weekly Drop",
                "public": False,
                "description": "Your curated language learning tracks for the week."
            }
            
            response_create = requests.post(url_create, headers=headers, json=data_create)
            
            if response_create.status_code not in [200, 201]:
                self.stdout.write(self.style.ERROR(f"Failed to create playlist: {response_create.text}"))
                return
                
            playlist_data = response_create.json()
            playlist_id = playlist_data['id']
            self.stdout.write(self.style.SUCCESS(f"Created: {playlist_data['name']}"))

            # 2. define the curated 5-10 songs for the week
            weekly_songs = [
                {"title": "Despacito", "artist": "Luis Fonsi"},
                {"title": "Bidi Bidi Bom Bom", "artist": "Selena"},
                {"title": "Danza Kuduro", "artist": "Don Omar"},
                {"title": "Vivir Mi Vida", "artist": "Marc Anthony"},
                {"title": "Con Altura", "artist": "ROSALÍA"}
            ]
            
            track_uris = []
            self.stdout.write("Searching for tracks...")
            
            # 3. loop through your curation and use your helper function
            for song in weekly_songs:
                result = search_spotify_track(song["title"], song["artist"], access_token)
                
                if result:
                    track_uris.append(f"spotify:track:{result['spotify_id']}")
                    self.stdout.write(f"  Found: {result['title']} by {result['artist']}")
                else:
                    self.stdout.write(self.style.WARNING(f"  Could not find: {song['title']}"))

            # 4. add the found tracks using spotipy's built-in method
            if track_uris:
                self.stdout.write("Adding tracks to playlist...")
                
                sp.playlist_add_items(playlist_id, track_uris)
                
                self.stdout.write(self.style.SUCCESS("Success! All tracks added."))
                self.stdout.write(f"Check your Spotify! URL: {playlist_data['external_urls']['spotify']}")
            
        except Exception as e:
            self.stdout.write(self.style.ERROR(f"An error occurred: {e}"))