import requests
import json
import time

URL = "http://127.0.0.1:8000/chat"
API_KEY = "PROTOTYPE_MASTER_KEY"

# Complex queries simulating transcripts from the Web Speech API
queries = [
    {
        "lang": "mr",
        "desc": "Marathi - Tractor Subsidy",
        "text": "माझ्याकडे 2 एकर जमीन आहे आणि मला ट्रॅक्टर घ्यायचा आहे. शासनाची कोणती योजना आहे?"
    },
    {
        "lang": "pa",
        "desc": "Punjabi - Crop Damage Compensation",
        "text": "ਮੇਰੀ ਫਸਲ ਮੀਂਹ ਕਾਰਨ ਖਰਾਬ ਹੋ ਗਈ ਹੈ, ਮੈਨੂੰ ਮੁਆਵਜ਼ਾ ਕਿਵੇਂ ਮਿਲੇਗਾ?"
    },
    {
        "lang": "te",
        "desc": "Telugu - Woman Farmer Seed Subsidy",
        "text": "నేను మహిళా రైతును, నాకు సబ్సిడీతో కూడిన విత్తనాలు కావాలి."
    },
    {
        "lang": "hi",
        "desc": "Hindi - Organic Farming Loan",
        "text": "मुझे जैविक खेती शुरू करनी है लेकिन मेरे पास पैसे नहीं हैं। क्या सरकार कोई लोन देती है?"
    },
    {
        "lang": "ta",
        "desc": "Tamil - Widow Financial Assistance",
        "text": "என் கணவர் இறந்துவிட்டார். விவசாயம் செய்ய எனக்கு ஏதேனும் நிதி உதவி உள்ளதா?"
    }
]

print("Starting Multilingual AI Intent Tests...\n" + "="*50)

for q in queries:
    print(f"\n[{q['desc']}]")
    print(f"User (Transcribed Speech): '{q['text']}'")
    
    payload = {
        "message": q['text'],
        "session_id": f"test-voice-{int(time.time())}",
        "language_hint": q['lang']
    }
    
    try:
        response = requests.post(
            URL, 
            json=payload, 
            headers={"Content-Type": "application/json", "X-API-Key": API_KEY}
        )
        if response.status_code == 200:
            data = response.json()
            matched_schemes = [s['scheme_name'] for s in data.get('schemes', [])]
            print(f"AI Response (Language: {data.get('language')}): {data.get('text')}")
            print(f"Matched Schemes: {matched_schemes if matched_schemes else 'None'}")
            print(f"Audio Generated: {'Yes' if data.get('audio_base64') else 'No'}")
        else:
            print(f"Error: Status Code {response.status_code}")
    except Exception as e:
        print(f"Connection Error: {e}")
    time.sleep(2) # Prevent rate limiting

print("\n" + "="*50 + "\nTesting Complete.")
