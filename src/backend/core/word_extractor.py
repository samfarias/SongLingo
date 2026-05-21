import json
import re
import string

def extractAndCleanWordsFromSongs():
  def clean_token(word):
      chars_to_strip = string.punctuation.replace("'", "").replace("-", "") + "♪♫„“»«¡¿"
      word = word.lower().strip(chars_to_strip)
      word = re.sub(r"^['-]+|['-]+$", "", word)
      return word

  def extract_unique_words(json_file_path):
      unique_words = set()
      
      with open(json_file_path, 'r', encoding='utf-8') as f:
        songs = json.load(f)
          
        for song in songs:
          lyrics = song.get("lyrics", "")
              
          # Split by whitespace to look at every single token
          tokens = lyrics.split()
              
          for token in tokens:
            cleaned = clean_token(token)
            # Ignore numbers or empty strings left over from pure punctuation
            if cleaned and not cleaned.isnumeric():
              unique_words.add(cleaned)
                      
      return list(unique_words)
  
  # Run the extraction
  unique_vocabulary = extract_unique_words("songs.json")
  for word in unique_vocabulary:
     print(f"{word},")


# --- COMMAND LINE TRIGGER BLOCK ---
if __name__ == "__main__":
   # Execute the function
   extractAndCleanWordsFromSongs()