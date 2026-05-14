import json
from django.core.management.base import BaseCommand
from core.models import Song, Word, Genre, Language

class Command(BaseCommand):
    help = 'Load songs and vocabulary from a JSON file'

    def add_arguments(self, parser):
        parser.add_argument('json_file', type=str, help='Path to the JSON file')

    def handle(self, *args, **kwargs):
        file_path = kwargs['json_file']
        
        with open(file_path, 'r', encoding='utf-8') as f:
            songs_data = json.load(f)

        for item in songs_data:
            # get or create foreignkeys
            lang, _ = Language.objects.get_or_create(
                language_name=item.get('language', 'Spanish')
            )
            genre, _ = Genre.objects.get_or_create(
                genre_name=item.get('genre', 'Pop')
            )

            # extract just the words for the JSON list
            vocab_dict = item.get('vocabulary', {})
            vocab_list = list(vocab_dict.keys())

            # 3. Create or Update the Song
            song, created = Song.objects.update_or_create(
                title=item['title'],
                artist=item['artist'],
                defaults={
                    'language': lang,
                    'genre': genre,
                    'lyrics': item.get('lyrics', ''),
                    'proficiency_level': item.get('proficiency_level', 'Beginner'),
                    'vocabulary_json': vocab_list,
                    'spotify_preview_url': item.get('spotify_preview_url', '')
                }
            )

            # generate the independent word database rows
            for word_text, details in vocab_dict.items():
                Word.objects.update_or_create(
                    word_text=word_text,
                    language=lang,
                    defaults={
                        'translation': details.get('translation', ''),
                        'definition': details.get('definition', ''),
                        'pronunciation': details.get('pronunciation', ''),
                        'proficiency_level': item.get('proficiency_level', 'Beginner')
                    }
                )
        
        self.stdout.write(self.style.SUCCESS(f'Successfully loaded {len(songs_data)} songs!'))