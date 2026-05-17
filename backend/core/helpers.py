import requests
import re
import string

def fetch_word_info(word_text):
    # Your API Endpoint
    url = f"https://freedictionaryapi.com/api/v1/entries/es/{word_text}?translations=true" 
    
    try:
        response = requests.get(url, timeout=5)
        
        # If the word isn't found (404) or server errors out, handle it gracefully
        if response.status_code != 200:
            return None
            
        # This automatically parses the JSON into native Python dicts/lists
        data = response.json()
        
        # Extract fields safely using .get() to prevent KeyErrors if the data is messy
        entries = data.get("entries", [])
        
        if not entries:
            return None
            
        word_details = entries[0]
        

        pronunciations_list = word_details.get("pronunciations", [])
        if pronunciations_list:
          first_pronunciation = pronunciations_list[0]
        
        pronunciation = first_pronunciation.get("text", "") or ""
        
        # Senses is a list, so grab the first sense to get the definition
        senses = word_details.get("senses", [])
        definition = senses[0].get("definition", "") if senses else ""
        
        return {
            "pronunciation": pronunciation,
            "definition": definition
        }

    except requests.RequestException:
        # Network timeout or DNS failure
        return None
    

def clean_and_format_word(word):
    word = word.lower()
    chars_to_strip = string.punctuation.replace("'", "").replace("-", "") + "¡¿"
    
    # Check if we are dealing with a phrase or a single word
    if " " in word.strip():
        # PHRASE LOGIC: Split, clean each token individually, and rejoin
        raw_words = word.split()
        cleaned_words = []
        
        for w in raw_words:
            cleaned_w = w.strip(chars_to_strip)
            cleaned_w = re.sub(r"^['-]+|['-]+$", "", cleaned_w)
            
            # Keep it if it wasn't just pure punctuation (i.e. not empty)
            if cleaned_w:
                cleaned_words.append(cleaned_w)
                
        return " ".join(cleaned_words)
        
    else:
        # SINGLE WORD LOGIC: Clean the single token directly
        cleaned_word = word.strip(chars_to_strip)
        cleaned_word = re.sub(r"^['-]+|['-]+$", "", cleaned_word)
        return cleaned_word