"""
Module: import_words
Description: Script for setting up the Django environment and executing bulk loading
             of parsed vocabulary words from a JSON file into the database.
"""
import json
import os
import django

# 1. Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings') 
django.setup()

from core.models import Word, Language # Adjust imports

def run_import():
    """
    Imports vocabulary words from a JSON data source file into the database.

    Purpose:
        Reads all vocabulary definitions from 'words.json', validates the target
        language, instantiates corresponding Word database objects, and performs 
        efficient bulk creation.

    Inputs:
        None.

    Outputs:
        None.

    Side Effects:
        - Reads the local 'words.json' file.
        - Database mutation: Bulk inserts Word records into the database.
        - Prints diagnostic success messages to standard output.
    """
    # Load your JSON file
    with open('words.json', 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Get the language instance (ID 1)
    try:
        lang = Language.objects.get(id=1)
    except Language.DoesNotExist:
        print("Language ID 1 does not exist.")
        return

    # Prepare a list of Word objects (not saved to DB yet)
    word_objects = [
        Word(
            language=lang,
            word_text=item['word_text'],
            translation=item['translation'],
            pronunciation=item['pronunciation'],
            definition=item['definition'],
            proficiency_level=item['proficiency_level']
        )
        for item in data
    ]

    # Bulk create for efficiency (batches of 1000 to avoid memory issues)
    Word.objects.bulk_create(word_objects, batch_size=1000)
    print(f"Successfully imported {len(word_objects)} words.")

# Run the function
if __name__ == '__main__':
    run_import()