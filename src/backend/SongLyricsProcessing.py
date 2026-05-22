"""
Module: SongLyricsProcessing
Description: Analyzes Spanish lyrics using spaCy NLP for grammatical complexity, 
             generates translations/definitions for vocabulary cards, and outputs 
             structured Django-compatible JSON song data.
"""
import os
import re
import time
import json
import random
from dotenv import load_dotenv
import lyricsgenius
import spacy
from deep_translator import GoogleTranslator

# load environment vars
load_dotenv()
token = os.environ.get("GENIUS_ACCESS_TOKEN")

if not token:
    print("Error: GENIUS_ACCESS_TOKEN not found in .env file.")
    exit()

# set up genius client
genius = lyricsgenius.Genius(token)
genius.verbose = False
genius.remove_section_headers = True
genius.timeout = 10 
genius.retries = 3

print("Loading spaCy Spanish model...")
try:
    nlp = spacy.load("es_core_news_sm")
except Exception:
    print("Error: Spanish model not found. Run: python -m spacy download es_core_news_sm")
    exit()

# Genre Mapping
GENRE_MAP = {
    "pop": "Pop",
    "reggaeton": "Reggaeton/Urbano",
    "urbano": "Reggaeton/Urbano",
    "regional": "Regional Mexican",
    "indie": "Indie Alternative",
    "alternative": "Indie Alternative",
    "tropical": "Tropical",
    "rock": "Rock"
}

def analyze_linguistics(lyrics_text):
    """
    Analyzes Spanish lyrics using NLP to determine grammatical and lexical complexity.

    Purpose:
        To calculate a linguistic complexity score and extract a vocabulary sample
        for the given Spanish song lyrics using morphological analysis.

    Inputs:
        lyrics_text (str): The raw text of the song lyrics to analyze.

    Outputs:
        dict: A dictionary containing:
            - "linguistic_score" (float): A calculated score based on vocabulary base, 
              grammar complexity penalties, and word speed penalties.
            - "vocab_sample" (list): A list of up to 10 unique non-stopwords longer than 3 letters.
        None: If the total word count is zero or the lyrics cannot be parsed.

    Side Effects:
        None.
    """
    doc = nlp(lyrics_text)
    
    total_words = 0
    unique_lemmas = set()
    subjunctive_count = 0
    conditional_count = 0
    complex_clause_count = 0
    
    for token in doc:
        if token.is_punct or token.is_space or token.like_num:
            continue
            
        total_words += 1
        
        # Track unique vocabulary, keeping words longer than 3 letters
        if not token.is_stop and len(token.lemma_) > 3:
            unique_lemmas.add(token.lemma_.lower())
            
        if token.pos_ == "SCONJ":
            complex_clause_count += 1
            
        if token.pos_ in ["VERB", "AUX"]:
            morphology = token.morph.to_dict()
            if morphology.get("Mood") == "Sub":
                subjunctive_count += 1
            elif morphology.get("Tense") == "Cond":
                conditional_count += 1

    if total_words == 0:
        return None
        
    vocab_base = len(unique_lemmas)
    grammar_penalty = (subjunctive_count * 5) + (conditional_count * 5) + (complex_clause_count * 2)
    speed_penalty = total_words * 0.05
    
    return {
        "linguistic_score": vocab_base + grammar_penalty + speed_penalty,
        "vocab_sample": list(unique_lemmas)[:10] # Grab up to 10 unique words for the flashcards
    }

def generate_vocab_dictionary(vocab_list):
    """
    Translates vocabulary words and compiles definitions and pronunciations.

    Purpose:
        Automates Spanish-to-English translation and placeholder phonetic/definition
        generation for each word in the provided vocabulary list.

    Inputs:
        vocab_list (list): A list of Spanish vocabulary words.

    Outputs:
        dict: A mapping of Spanish words to sub-dictionaries containing:
            - "translation" (str): English translation of the word.
            - "definition" (str): Definition or placeholder text.
            - "pronunciation" (str): Pseudo-phonetic pronunciation text.

    Side Effects:
        Initiates network requests to the GoogleTranslator API for each word.
    """
    vocab_dict = {}
    translator_en = GoogleTranslator(source='es', target='en')
    
    for word in vocab_list:
        try:
            translation = translator_en.translate(word)
            # pseudo-phonetic generation for the placeholder
            pronunciation = "-".join([chunk.upper() if i % 2 != 0 else chunk for i, chunk in enumerate(word.split())]) or word
            
            vocab_dict[word] = {
                "translation": translation.lower() if translation else "",
                "definition": f"Palabra en español: {word}", # Placeholder definition
                "pronunciation": pronunciation
            }
        except Exception:
            continue
            
    return vocab_dict

def run_pipeline(input_file="rock.txt", output_file="songs.json", genre_category="Rock"):
    """
    Executes the complete end-to-end processing pipeline for a list of songs.

    Purpose:
        Reads titles and artists from a text file, searches Genius for lyrics,
        runs NLP-based complexity scoring, generates vocabulary cards, sorts
        songs by proficiency level, and outputs a formatted JSON file.

    Inputs:
        input_file (str): Path to the input text file containing "Title - Artist" lines.
        output_file (str): Path to the output JSON file where processed data is saved.
        genre_category (str): The genre classification to associate with the songs.

    Outputs:
        None.

    Side Effects:
        - Reads local text files.
        - Writes data to the output JSON file.
        - Executes network queries to the Genius API.
        - Executes network queries to the GoogleTranslator API.
        - Prints diagnostic search and success logs to standard output.
    """
    if not os.path.exists(input_file):
        print(f"Error: Could not find '{input_file}' in this folder.")
        return

    print(f"Reading songs from {input_file}...")
    with open(input_file, "r", encoding="utf-8") as f:
        lines = [line.strip() for line in f if line.strip()]

    processed_songs = []
    
    # resolve the official genre string
    official_genre = GENRE_MAP.get(genre_category.lower(), "Pop")

    for line in lines:
        if "–" not in line and "-" not in line:
            continue
            
        separator = "–" if "–" in line else "-"
        parts = line.split(separator)
        title = parts[0].strip()
        artist_raw = parts[1].strip()
        artist = re.sub(r'\(.*?\)', '', artist_raw).strip()

        print(f"Searching: '{title}' by {artist}...", end=" ", flush=True)
        
        try:
            song = genius.search_song(title, artist)
            if song and song.lyrics:
                lyric_data = analyze_linguistics(song.lyrics)
                
                if lyric_data:
                    vocab_dict = generate_vocab_dictionary(lyric_data["vocab_sample"])
                    
                    processed_songs.append({
                        "title": title,
                        "artist": artist,
                        "genre": official_genre,
                        "language": "Spanish",
                        "lyrics": song.lyrics,
                        "linguistic_score": lyric_data["linguistic_score"],
                        "vocabulary": vocab_dict
                    })
                    print(f"[Success: Score {lyric_data['linguistic_score']:.1f}]")
                else:
                    print("[Error: No parsable words]")
            else:
                print("[Not Found]")
            
            time.sleep(1) 

        except Exception as e:
            print(f"[API Error: {e}]")

    if not processed_songs:
        print("No songs were successfully processed. Exiting.")
        return

    # sort dynamically based on NLP score
    processed_songs.sort(key=lambda x: x["linguistic_score"])
    
    chunk_size = max(1, len(processed_songs) // 3)
    
    final_json_data = []
    
    for index, item in enumerate(processed_songs):
        if index < chunk_size:
            item["proficiency_level"] = "Beginner"
        elif index < chunk_size * 2:
            item["proficiency_level"] = "Intermediate"
        else:
            item["proficiency_level"] = "Advanced"
            
        # Clean up the JSON before export (remove the internal linguistic_score)
        del item["linguistic_score"]
        final_json_data.append(item)

    # export directly to the JSON format Django needs
    with open(output_file, "w", encoding="utf-8") as out:
        json.dump(final_json_data, out, ensure_ascii=False, indent=2)

    print(f"\nProcessing complete! Successfully generated {len(final_json_data)} fully-mapped songs in {output_file}.")
    print("Ready to run: python manage.py load_songs songs.json")

if __name__ == "__main__":
    # sample usage: change input_file and genre_category for each list you process
    run_pipeline(input_file="rock.txt", output_file="songs.json", genre_category="Rock")