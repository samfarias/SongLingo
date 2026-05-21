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

1. **Create a virtual environment**:
   ```bash
   python3 -m venv venv
   . venv/bin/activate
   ```

2. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Environment Variables**:
   Ensure you have a `.env` file in the root directory with the necessary keys (SECRET_KEY, SPOTIFY_CLIENT_ID, etc.).

4. **Run Migrations**:
   ```bash
   python manage.py migrate
   ```

5. **Import Initial Data**:
   If you have a `words.json` file, you can import it using:
   ```bash
   python import_words.py
   ```

6. **Start the server**:
   ```bash
   python manage.py runserver
   ```
   The backend will be available at `http://127.0.0.1:8000`.

### Running with Docker
The backend is included in the root `docker-compose.yml`. To run just the backend service:
```bash
docker-compose up web
```

## Project Structure
- `backend/`: Configuration and settings.
- `core/`: Main app containing models, serializers, and views.
- `SongLyricsProcessing.py`: Utility for processing and translating lyrics.
- `import_words.py`: Script to populate the database from JSON data.

## Code Style
This component follows the [PEP 8](https://peps.python.org/pep-0008/) style guide.
