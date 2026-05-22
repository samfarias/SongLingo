# SongLingo Backend

This is the backend service for SongLingo, built with Django and Django REST Framework. It handles the core logic for lyric processing, word management, and language learning features.

## Tech Stack
- **Framework**: Django 4.2+
- **API**: Django REST Framework (DRF)
- **Database**: PostgreSQL (Production/Docker)
- **NLP**: spaCy (for Spanish lyric processing)
- **APIs**: Spotify (via Spotipy), Genius (via LyricsGenius), FreeDictionaryAPI

## Setup & Installation

### Local Development (without Docker)

1. **Navigate to backend directory if not already there**:
   ```bash
   cd src/backend
   ```

2. **Create a virtual environment**:
   ```bash
   python3.11 -m venv venv
   . venv/bin/activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Environment Variables**:
   Ensure you have a `.env` file in the root directory with the necessary keys (SECRET_KEY, SPOTIFY_CLIENT_ID, etc.).

5. **Run Migrations**:
   ```bash
   python manage.py migrate
   ```

6. **Import Initial Data**:
   If you have a `words.json` file, you can import it using:
   ```bash
   python import_words.py
   ```

7. **Start the server**:
   ```bash
   python manage.py runserver
   ```
   The backend will be available at `http://127.0.0.1:8000`.
   

## Project Structure
- `backend/`: Configuration and settings.
- `core/`: Main app containing models, serializers, and views.
- `SongLyricsProcessing.py`: Utility for processing and translating lyrics.
- `import_words.py`: Script to populate the database from JSON data.

## Code Style
This component follows the [PEP 8](https://peps.python.org/pep-0008/) style guide.
