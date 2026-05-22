import os
import time
import requests
from django.core.management.base import BaseCommand
from core.models import Song
from dotenv import load_dotenv

load_dotenv()

class Command(BaseCommand):
    help = 'Fetches and seeds Spotify IDs for all songs currently missing them in the database.'

    def get_spotify_access_token(self):
        """Authenticates with Spotify using Client Credentials flow."""
        client_id = os.environ.get('SPOTIFY_CLIENT_ID')
        client_secret = os.environ.get('SPOTIFY_CLIENT_SECRET')

        if not client_id or not client_secret:
            self.stderr.write(self.style.ERROR("Missing SPOTIFY_CLIENT_ID or SPOTIFY_CLIENT_SECRET in .env"))
            return None

        auth_url = 'https://accounts.spotify.com/api/token'
        response = requests.post(auth_url, {
            'grant_type': 'client_credentials',
            'client_id': client_id,
            'client_secret': client_secret,
        })

        if response.status_code != 200:
            self.stderr.write(self.style.ERROR(f"Failed to authenticate with Spotify: {response.json()}"))
            return None

        return response.json().get('access_token')

    def handle(self, *args, **options):
        self.stdout.write("Authenticating with Spotify...")
        access_token = self.get_spotify_access_token()
        if not access_token:
            return

        headers = {
            'Authorization': f'Bearer {access_token}'
        }


        songs_to_update = Song.objects.filter(spotify_id__isnull=True) | Song.objects.filter(spotify_id__exact='')
        total_songs = songs_to_update.count()

        if total_songs == 0:
            self.stdout.write(self.style.SUCCESS("All songs already have a Spotify ID!"))
            return

        self.stdout.write(f"Found {total_songs} songs missing Spotify data. Starting search...")

        # Loop and fetch
        success_count = 0
        for song in songs_to_update:
            # Format the query strictly to Track and Artist to avoid bad matches
            query = f"track:{song.title} artist:{song.artist}"
            search_url = f"https://api.spotify.com/v1/search"
            params = {
                'q': query,
                'type': 'track',
                'limit': 1
            }

            try:
                response = requests.get(search_url, headers=headers, params=params)
                
                # Handle rate limiting safely
                if response.status_code == 429:
                    retry_after = int(response.headers.get('Retry-After', 3))
                    self.stdout.write(self.style.WARNING(f"Rate limited. Sleeping for {retry_after} seconds..."))
                    time.sleep(retry_after)
                    response = requests.get(search_url, headers=headers, params=params)

                response.raise_for_status()
                data = response.json()

                tracks = data.get('tracks', {}).get('items', [])
                
                if tracks:
                    best_match = tracks[0]
                    song.spotify_id = best_match.get('id')
                    
                    # Grab the preview URL if it exists, just to populate the existing field
                    preview_url = best_match.get('preview_url')
                    if preview_url:
                        song.spotify_preview_url = preview_url

                    song.save()
                    success_count += 1
                    self.stdout.write(self.style.SUCCESS(f"Linked: {song.title} -> {song.spotify_id}"))
                else:
                    self.stdout.write(self.style.WARNING(f"No Spotify match found for: {song.title} by {song.artist}"))

            except Exception as e:
                self.stderr.write(self.style.ERROR(f"Error fetching {song.title}: {str(e)}"))

            # Small sleep to respect rate limits during bulk operations
            time.sleep(0.3)

        self.stdout.write(self.style.SUCCESS(f"\nFinished! Successfully mapped {success_count} out of {total_songs} songs."))