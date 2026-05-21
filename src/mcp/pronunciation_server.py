from fastmcp import FastMCP
from gtts import gTTS
import base64
import io

# initialize the server
mcp = FastMCP("songlingo-pronunciation")

@mcp.tool()
def get_audio_and_phonetics(word: str, language_code: str = "es", region_tld: str = "com.mx") -> dict:
    """get the phonetic text and native audio for a word."""
    
    # 1. your text phonetics (we'll keep it dummy for now)
    dummy_phonetic = f"phonetics for {word}"
    
    # 2. generate the native audio using gtts
    tts = gTTS(text=word, lang=language_code, tld=region_tld)
    
    # 3. the "pro" move: save to memory instead of the hard drive
    audio_fp = io.BytesIO()
    tts.write_to_fp(audio_fp)
    
    # convert the raw audio to a base64 string so we can send it over the internet
    audio_base64 = base64.b64encode(audio_fp.getvalue()).decode('utf-8')
    
    return {
        "word": word,
        "phonetic": dummy_phonetic,
        "audio_base64": audio_base64
    }

if __name__ == "__main__":
    mcp.run(transport="sse", host="0.0.0.0", port=8001)
