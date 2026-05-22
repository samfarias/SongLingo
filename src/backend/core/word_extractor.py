"""
Module: word_extractor
Description: Commands and scripts to parse unique tokens and Spanish vocabulary
             from JSON lyrics files and output standard word logs.
"""
import json
import re
import string

def extractAndCleanWordsFromSongs():
  """
  Extracts and normalizes all unique vocabulary words from songs.json.

  Purpose:
      Runs parsing loops to compile a complete list of unique foreign words 
      used across all registered tracks, filtering numerical structures.

  Inputs:
      None.

  Outputs:
      None.

  Side Effects:
      - Reads local 'songs.json' file via helper structure.
      - Prints unique words to standard output.
  """
  def clean_token(word):
      """
      Cleans punctuation and normalizes an individual word token.

      Inputs:
          word (str): The raw word token.

      Outputs:
          str: Cleaned lowercase word.
      """
      chars_to_strip = string.punctuation.replace("'", "").replace("-", "") + "♪♫„“»«¡¿"
      word = word.lower().strip(chars_to_strip)
      word = re.sub(r"^['-]+|['-]+$", "", word)
      return word

  def extract_unique_words(json_file_path):
      """
      Loads the specified JSON file and parses unique words from song lyrics.

      Inputs:
          json_file_path (str): Target JSON filename.

      Outputs:
          list: Sorted list of unique vocabulary word tokens.
      """
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