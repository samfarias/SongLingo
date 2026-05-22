"""
Module: test_spotify
Description: Diagnostic integration test script for validating credentials configuration 
             and operational connectivity of the SpotifyService client.
"""
from spotify_services import SpotifyService
import os
import requests

def run_test():
    """
    Executes integration check scenarios against the Spotify Service API wrapper.

    Purpose:
        Verifies environmental credentials, requests an OAuth client token,
        and queries a search endpoint for a standard track to validate JSON formats.

    Inputs:
        None.

    Outputs:
        None.

    Side Effects:
        - Checks for environment variables 'SPOTIFY_CLIENT_ID' and 'SPOTIFY_CLIENT_SECRET'.
        - Executes network queries to the Spotify API.
        - Prints diagnostic success and error summaries to standard output.
    """
    print("--- Starting Spotify Service Test ---")
    
    # 0. The Sanity Check
    client_id = os.getenv('SPOTIFY_CLIENT_ID')
    client_secret = os.getenv('SPOTIFY_CLIENT_SECRET')
    
    if not client_id:
        print("🛑 ERROR: Missing SPOTIFY_CLIENT_ID")
        return
    if not client_secret:
        print("🛑 ERROR: Missing SPOTIFY_CLIENT_SECRET in .env file!")
        return
        
    print(f"✅ Credentials loaded! ID starts with: {client_id[:5]}...")
    
    # Initialize the engine
    spotify = SpotifyService()
    
    # Test 1: Can we get a token?
    print("\n1. Requesting Access Token...")
    try:
        token = spotify._get_access_token()
        print(f"   Success! Token starts with: {token[:15]}...")
    except requests.exceptions.HTTPError as e:
        print(f"   🛑 HTTP Error: {e}")
        print(f"   🛑 Spotify Response: {e.response.text}") # <--- This tells us EXACTLY why it failed
        return
    
    # Test 2: Can we search a track?
    print("\n2. Searching for a track...")
    try:
        result = spotify.search_track(title="Despacito", artist="Luis Fonsi")
        print("   Search Result:")
        print(f"   Spotify ID: {result.get('spotify_id')}")
        print(f"   Preview URL: {result.get('preview_url')}")
    except requests.exceptions.HTTPError as e:
        print(f"   🛑 HTTP Error during search: {e}")
        print(f"   🛑 Spotify Response: {e.response.text}")
    
    print("\n--- Test Complete ---")


if __name__ == '__main__':
    run_test()