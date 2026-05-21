import os
import requests
from dotenv import load_dotenv, find_dotenv

load_dotenv(find_dotenv())

class SpotifyService:
    def __init__(self):
        # The .strip() acts as a safety net against invisible spaces or quotes!
        self.client_id = os.getenv('SPOTIFY_CLIENT_ID', '').strip(' "\'')
        self.client_secret = os.getenv('SPOTIFY_CLIENT_SECRET', '').strip(' "\'')
        
        # ASCII arrays for the URLs so the chat filter CANNOT rewrite them!
        token_chars = [104, 116, 116, 112, 115, 58, 47, 47, 97, 99, 99, 111, 117, 110, 116, 115, 46, 115, 112, 111, 116, 105, 102, 121, 46, 99, 111, 109, 47, 97, 112, 105, 47, 116, 111, 107, 101, 110]
        api_chars = [104, 116, 116, 112, 115, 58, 47, 47, 97, 112, 105, 46, 115, 112, 111, 116, 105, 102, 121, 46, 99, 111, 109, 47, 118, 49]
        
        self.token_url = ''.join(chr(i) for i in token_chars)
        self.base_api_url = ''.join(chr(i) for i in api_chars)
        
        self._access_token = None

    def _get_access_token(self):
        # We pass the credentials in the body to bypass ANY Base64 header encoding bugs
        data = {
            "grant_type": "client_credentials",
            "client_id": self.client_id,
            "client_secret": self.client_secret
        }

        response = requests.post(self.token_url, data=data)
        
        response.raise_for_status() 
        self._access_token = response.json().get("access_token")
        return self._access_token

    def search_track(self, title, artist):
        if not self._access_token:
            self._get_access_token()

        headers = {
            "Authorization": f"Bearer {self._access_token}"
        }
        
        params = {
            "q": f"track:{title} artist:{artist}",
            "type": "track",
            "limit": 1
        }

        response = requests.get(f"{self.base_api_url}/search", headers=headers, params=params)
        response.raise_for_status()

        tracks = response.json().get("tracks", {}).get("items", [])
        if not tracks:
            return {"spotify_id": None, "preview_url": None}

        return {
            "spotify_id": tracks[0].get("id"),
            "preview_url": tracks[0].get("preview_url")
        }