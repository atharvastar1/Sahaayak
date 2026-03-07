"""
llm.py — Production LLM service
- PRIMARY:  Amazon Bedrock (Nova Lite / Claude) via llm_bedrock.py
- FALLBACK: Groq (llama-3.3-70b) when Bedrock is not configured
- Supports all 22 scheduled languages of India + English
- Strict language enforcement: responses always in the user's selected language
- Async with configurable timeout + session memory
- Graceful fallback on timeout or API error
"""

import os
import asyncio
from groq import AsyncGroq
from typing import List, Dict
from dotenv import load_dotenv

from cache import session_memory
from logger import get_logger

load_dotenv()
log = get_logger("llm")

_client = AsyncGroq(api_key=os.getenv("GROQ_API_KEY"))
LLM_TIMEOUT = int(os.getenv("LLM_TIMEOUT_SECONDS", 20))

# ── Bedrock integration (primary LLM engine) ───────────────────────────────────
try:
    from llm_bedrock import generate_explanation_bedrock, bedrock_available
    _BEDROCK_IMPORTED = True
except ImportError:
    _BEDROCK_IMPORTED = False
    def bedrock_available(): return False
    async def generate_explanation_bedrock(*args, **kwargs): return None


def get_active_llm_engine() -> str:
    """
    Returns the name of the LLM engine that will be used for this request.
    Used by /health and /engine endpoints for AWS compliance visibility.
    """
    return "bedrock" if (_BEDROCK_IMPORTED and bedrock_available()) else "groq"


# ── Language detection ─────────────────────────────────────────────────────────
def detect_language(text: str, language_hint: str = "") -> str:
    """
    Returns BCP-47 language code. All 22 Indian scheduled languages + English supported.
    If language_hint is provided by the frontend (user's selected language), ALWAYS trust it.
    This is the primary path — auto-detection is only a fallback when no hint is given.
    """
    # ALL 23 supported codes — trust the frontend hint unconditionally when provided
    ALL_SUPPORTED = {
        "en", "hi", "mr", "pa", "te", "ta", "kn", "ml", "bn", "gu",
        "or", "as", "ur", "ne", "sd", "ks", "mai", "sa", "kok", "doi",
        "mni", "sat", "brx"
    }
    if language_hint and language_hint.strip().lower() in ALL_SUPPORTED:
        return language_hint.strip().lower()

    # Script-based detection
    # Gurmukhi (Punjabi) U+0A00–U+0A7F
    if any('\u0A00' <= c <= '\u0A7F' for c in text):
        return "pa"
    # Gujarati U+0A80–U+0AFF
    if any('\u0A80' <= c <= '\u0AFF' for c in text):
        return "gu"
    # Oriya/Odia U+0B00–U+0B7F
    if any('\u0B00' <= c <= '\u0B7F' for c in text):
        return "or"
    # Tamil U+0B80–U+0BFF
    if any('\u0B80' <= c <= '\u0BFF' for c in text):
        return "ta"
    # Telugu U+0C00–U+0C7F
    if any('\u0C00' <= c <= '\u0C7F' for c in text):
        return "te"
    # Kannada U+0C80–U+0CFF
    if any('\u0C80' <= c <= '\u0CFF' for c in text):
        return "kn"
    # Malayalam U+0D00–U+0D7F
    if any('\u0D00' <= c <= '\u0D7F' for c in text):
        return "ml"
    # Bengali/Assamese U+0980–U+09FF
    if any('\u0980' <= c <= '\u09FF' for c in text):
        # Assamese-specific: ৰ ৱ
        if any(c in {'\u09F0', '\u09F1'} for c in text):
            return "as"
        return "bn"
    # Devanagari U+0900–U+097F (Hindi, Marathi, Sanskrit, Nepali, Maithili, Dogri, Konkani, Bodo)
    if any('\u0900' <= c <= '\u097F' for c in text):
        marathi_markers = {
            "आहे", "आहेत", "होतं", "होती", "होता", "होते", "आणि",
            "मला", "तुला", "त्याला", "तिला", "आम्हाला", "तुम्हाला",
            "माझं", "पाहिजे", "करायचं", "कशासाठी", "नको", "झाली"
        }
        if '\u0933' in text or any(m in text for m in marathi_markers):
            return "mr"
        return "hi"

    # Romanized Hindi keyword check
    hindi_words = {
        "kisan", "yojana", "sahayata", "madad", "sarkari", "garib",
        "ghar", "mahila", "pension", "ration", "bima", "shiksha",
        "rozgar", "mujhe", "chahiye", "kya", "kaun", "kaise",
    }
    if set(text.lower().split()) & hindi_words:
        return "hi"
    return "en"


# ── System prompts for all 22 Indian languages ─────────────────────────────────
def _make_prompt(lang_name: str, instruction: str, life_event: str = "") -> str:
    event_context = ""
    if life_event:
        event_context = f"\nUSER CONTEXT: The user has identified as a '{life_event}'. Prioritize schemes for this demographic."

    return f"""You are Sahaayak, a helpful Indian Government Scheme advisor for rural and underserved citizens.
{event_context}

Rules:
1. ONLY reference the schemes listed below — never invent schemes.
2. Dialect Normalization: If the user speaks in a local dialect (e.g., Bhojpuri, Ahirani, Bundeli), normalize it mentally and respond in standard {lang_name}.
3. Simple Language: Use clear, simple language suitable for someone with low digital literacy.
4. Guided Application: If a user shows interest in a scheme, provide a clear 3-step guide on how to apply.
5. Empathy: Be encouraging and respectful.
6. CRITICAL: Respond EXCLUSIVELY in {lang_name}. Do NOT mix any other language. {instruction}
7. If no retrieved schemes match the query, honestly say so in {lang_name} and suggest trying different words.
"""

_PROMPTS_META = {
    # ── Major languages ────────────────────────────────────────────────────────
    "en":  "Write in clear, simple English.",
    "hi":  "लिखें केवल हिंदी में, देवनागरी लिपि में।",
    "mr":  "फक्त मराठीत लिहा, देवनागरी लिपीत।",
    "pa":  "ਸਿਰਫ਼ ਪੰਜਾਬੀ ਵਿੱਚ ਲਿਖੋ, ਗੁਰਮੁਖੀ ਲਿਪੀ ਵਿੱਚ।",
    "te":  "తెలుగులో మాత్రమే రాయండి, తెలుగు లిపిలో।",
    "ta":  "தமிழில் மட்டும் எழுதுங்கள், தமிழ் எழுத்தில்.",
    "kn":  "ಕನ್ನಡದಲ್ಲಿ ಮಾತ್ರ ಬರೆಯಿರಿ, ಕನ್ನಡ ಲಿಪಿಯಲ್ಲಿ.",
    "ml":  "മലയാളത്തിൽ മാത്രം എഴുതുക, മലയാളം ലിപിയിൽ.",
    "bn":  "শুধুমাত্র বাংলায় লিখুন, বাংলা হরফে।",
    "gu":  "ફક્ત ગુજરાતીમાં લખો, ગુજરાતી લિપિમાં.",
    "or":  "ଓଡ଼ିଆରେ ଲେଖ, ଓଡ଼ିଆ ଲିପିରେ।",
    "as":  "অসমীয়াত লিখক, অসমীয়া আখৰত।",
    "ur":  "صرف اردو میں لکھیں، نستعلیق رسم الخط میں۔",
    "ne":  "केवल नेपालीमा लेख्नुहोस्, देवनागरी लिपिमा।",
    "sd":  "صرف سنڌيءَ ۾ لکو، عربي رسم الخط ۾۔",
    "ks":  "کٲشُر زبانہ مَنز لێکھو، کشمیری رسم الخط مَنز۔",
    # ── Scheduled languages ───────────────────────────────────────────────────
    "mai": "मैथिलीमे मात्र लिखू, देवनागरी लिपिमे।",
    "sa":  "केवलं संस्कृते लिखतु, देवनागरीलिप्याम्।",
    "kok": "फकत कोंकणीत बरय, देवनागरी लिपींत।",
    "doi": "सिर्फ डोगरी च लिखो, देवनागरी लिपी च।",
    "mni": "ꯃꯅꯤꯄꯨꯔꯤꯗꯥ ꯃꯌꯥꯝ ꯁꯤꯖꯤꯟꯅꯕ꯭ꯋꯥꯏꯗꯕꯥ ꯂꯩꯈꯟꯕꯤꯌꯨ.",
    "sat": "ᱥᱟᱱᱛᱟᱲᱤ ᱨᱮ ᱢᱟᱹᱛᱤᱭᱟᱹ ᱟᱡᱚᱢ ᱠᱟᱜ.",
    "brx": "बडो भाषायाव लिर, देवनागरी लिपिजों।",
}

# ── Fallback messages for all 22 languages ─────────────────────────────────────
_FALLBACKS = {
    "en":  "Sorry, I couldn't find matching government schemes for your query. Please try rephrasing.",
    "hi":  "माफ करें, आपके सवाल से मेल खाती कोई सरकारी योजना नहीं मिली। कृपया अलग शब्दों में पूछें।",
    "mr":  "माफ करा, तुमच्या प्रश्नाशी जुळणारी कोणतीही सरकारी योजना मिळाली नाही। कृपया वेगळ्या शब्दांत विचारा।",
    "pa":  "ਮਾਫ਼ ਕਰਨਾ, ਤੁਹਾਡੇ ਸਵਾਲ ਨਾਲ ਮੇਲ ਖਾਂਦੀ ਕੋਈ ਸਰਕਾਰੀ ਯੋਜਨਾ ਨਹੀਂ ਮਿਲੀ। ਕਿਰਪਾ ਕਰਕੇ ਵੱਖ ਸ਼ਬਦਾਂ ਵਿੱਚ ਪੁੱਛੋ।",
    "te":  "క్షమించండి, మీ ప్రశ్నకు సరిపోయే ప్రభుత్వ పథకాలు కనుగొనబడలేదు. దయచేసి వేరే మాటలలో అడగండి।",
    "ta":  "மன்னிக்கவும், உங்கள் கேள்விக்கு பொருத்தமான திட்டங்கள் கிடைக்கவில்லை. வேறு வார்த்தைகளில் கேளுங்கள்.",
    "kn":  "ಕ್ಷಮಿಸಿ, ನಿಮ್ಮ ಪ್ರಶ್ನೆಗೆ ಸರಿಹೊಂದುವ ಸರ್ಕಾರಿ ಯೋಜನೆಗಳು ಸಿಗಲಿಲ್ಲ। ದಯವಿಟ್ಟು ಬೇರೆ ಪದಗಳಲ್ಲಿ ಕೇಳಿ।",
    "ml":  "ക്ഷമിക്കണം, നിങ്ങളുടെ ചോദ്യത്തിന് ഇണങ്ങുന്ന ഒരു പദ്ധതിയും ലഭ്യമായില്ല। ദയവായി മറ്റ് വാക്കുകളിൽ ചോദിക്കൂ.",
    "bn":  "দুঃখিত, আপনার প্রশ্নের সাথে মিলে এমন কোনো সরকারি প্রকল্প পাওয়া যায়নি। অন্য শব্দে জিজ্ঞেস করুন।",
    "gu":  "માફ કરો, તમારા પ્રશ્ન સાથે મેળ ખાતી કોઈ સરકારી યોજના મળી નહીં. કૃપા કરીને અન્ય શબ્દોમાં પૂછો.",
    "or":  "କ୍ଷମା କରନ୍ତୁ, ଆପଣଙ୍କ ପ୍ରଶ୍ନ ସହ ମେଳ ଖାଉଥିବା ଯୋଜନା ମିଳିଲା ନାହିଁ। ଅନ୍ୟ ଶବ୍ଦରେ ପଚାରନ୍ତୁ।",
    "as":  "দুঃখিত, আপোনাৰ প্ৰশ্নৰ সৈতে মিল থকা কোনো আঁচনি পোৱা নগ'ল। অন্য শব্দেৰে সুধক।",
    "ur":  "معذرت، آپ کے سوال سے ملتی کوئی سرکاری اسکیم نہیں ملی۔ براہ کرم الفاظ بدل کر پوچھیں۔",
    "ne":  "माफ गर्नुस्, तपाईंको प्रश्नसँग मेल खाने सरकारी योजना फेला परेन। अन्य शब्दमा सोध्नुहोस्।",
    "sd":  "معاف ڪجو، توهان جي سوال سان ملندڙ ڪا به سرڪاري اسڪيم نه ملي. ٻين لفظن ۾ پڇو.",
    "ks":  "معاف کٔریو، تہٕ سؤالَس منز میل کھانہِ کانٛہ یوجنا نہ ملیٖ. گۄڈنیچ لفظن مَنز پُچھِو.",
    "mai": "माफ करू, तोहर प्रश्न सँ मेल खाइत कोनो सरकारी योजना नहि भेटल। अलग शब्दमे पूछू।",
    "sa":  "क्षम्यताम्, भवतः प्रश्नेन सह मेलं खादन्ती काचिदपि सरकारी योजना न लब्धा। अन्यैः शब्दैः पृच्छतु।",
    "kok": "माफ करात, तुमच्या प्रश्नाक जुळोवन येवपी कसलीच सरकारी योजना मेळोना। वेगळ्या उतरांनी विचारात।",
    "doi": "माफ करो, तुआड़े सवाल नाल मिलदी कोई सरकारी योजना नेईं लब्भी। होर शब्दां च पुच्छो।",
    "mni": "ꯃꯑꯣꯡ ꯂꯧʘ, ꯅꯨꯡꯒꯤ ꯇꯦꯡꯕꯥꯙꯒꯤ ꯁꯥꯟꯗꯤꯒꯤ ꯁꯔꯀꯥꯔꯤ ꯌꯣꯖꯅꯥ ꯅꯠꯇꯦ.",
    "sat": "ᱵᱟᱡᱟᱣ ᱢᱮ, ᱟᱢᱟᱜ ᱥᱮᱸᱫᱽᱨᱟ ᱥᱟᱫᱷᱩ ᱡᱟᱱᱟᱢ ᱠᱟᱫᱮᱭᱟ.",
    "brx": "माफ रावो, नांगौ मासिनि बिजाब आरो बिसोर फोरनि मेलेब्ला खोनाय जायो नाय।",
}

_TIMEOUTS = {
    "en": "The service is busy right now. Please try again in a moment.",
    "hi": "सर्वर अभी व्यस्त है। कृपया थोड़ी देर बाद पुनः प्रयास करें।",
    "mr": "सर्व्हर आत्ता व्यस्त आहे. कृपया थोड्या वेळाने पुन्हा प्रयत्न करा.",
    "pa": "ਸਰਵਰ ਹੁਣੇ ਵਿਅਸਤ ਹੈ। ਕਿਰਪਾ ਕਰਕੇ ਥੋੜੀ ਦੇਰ ਬਾਅਦ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।",
    "te": "సర్వర్ ఇప్పుడు బిజీగా ఉంది. దయచేసి కొంత సేపటి తర్వాత మళ్ళీ ప్రయత్నించండి.",
    "ta": "சேவையகம் இப்போது பிஸியாக உள்ளது. சற்று நேரம் கழித்து மீண்டும் முயற்சிக்கவும்.",
    "kn": "ಸರ್ವರ್ ಈಗ ಬಿಝಿಯಾಗಿದೆ. ಸ್ವಲ್ಪ ಸಮಯದ ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.",
    "ml": "സർവ്വർ ഇപ്പോൾ തിരക്കിലാണ്. കുറച്ചു നേരം കഴിഞ്ഞ് വീണ്ടും ശ്രമിക്കൂ.",
    "bn": "সার্ভার এখন ব্যস্ত। কিছুক্ষণ পরে আবার চেষ্টা করুন।",
    "gu": "સર્વર હમણાં વ્યસ્ત છે. કૃપા કરીને થોડી વાર પછી ફરી પ્રયત્ન કરો.",
}


# ── Main async function ────────────────────────────────────────────────────────
async def generate_explanation(
    query:      str,
    schemes:    List[Dict],
    language:   str = "en",
    session_id: str = "default",
    life_event: str = "",
) -> str:
    """
    Generates a natural language response in the user's native tongue.
    Prioritizes Bedrock Nova Lite; falls back to Groq Llama 3 on failure.
    """
    full_lang_name = {
        "hi": "Hindi", "mr": "Marathi", "pa": "Punjabi", "te": "Telugu",
        "ta": "Tamil", "kn": "Kannada", "ml": "Malayalam", "bn": "Bengali",
        "gu": "Gujarati", "or": "Odia", "as": "Assamese", "ur": "Urdu",
        "ne": "Nepali", "sd": "Sindhi", "ks": "Kashmiri", "en": "English",
        "mai": "Maithili", "sa": "Sanskrit", "kok": "Konkani", "doi": "Dogri",
        "mni": "Manipuri", "sat": "Santali", "brx": "Bodo"
    }.get(language, "English")

    lang_instruction = _PROMPTS_META.get(language, "Write in clear, simple English.")
    system_prompt = _make_prompt(full_lang_name, lang_instruction, life_event)

    if not schemes:
        return _FALLBACKS.get(language, _FALLBACKS["en"])

    # ── 1. Try Bedrock ─────────────────────────────────────────────────────────
    bedrock_result = await generate_explanation_bedrock(
        query=query, schemes=schemes, language=language, session_id=session_id
    )
    if bedrock_result:
        log.info("LLM engine: bedrock", extra={"ctx_session": session_id})
        if session_id:
            session_memory.add_turn(session_id, "user", query)
            session_memory.add_turn(session_id, "assistant", bedrock_result)
        return bedrock_result

    log.info("LLM engine: groq (bedrock unavailable/fallback)", extra={"ctx_session": session_id})

    context = "\n".join(
        f"Scheme: {s['scheme_name']}\nBenefits: {s['benefits']}\nEligibility: {s['eligibility']}\n"
        for s in schemes
    )

    system_prompt = _PROMPTS.get(language, _PROMPTS["en"])
    history = session_memory.get_history(session_id)[-6:]
    messages = [{"role": "system", "content": system_prompt}]
    messages.extend(history)
    messages.append({
        "role": "user",
        "content": (
            f"User Query: {query}\n\n"
            f"Retrieved Schemes:\n{context}\n\n"
            f"Please explain which scheme(s) are most relevant for this user. "
            f"IMPORTANT: Your entire response must be in {language} language only."
        )
    })

    try:
        response = await asyncio.wait_for(
            _client.chat.completions.create(
                model="llama-3.3-70b-versatile",
                messages=messages,
                temperature=0.3,
                max_tokens=350,
            ),
            timeout=LLM_TIMEOUT,
        )
        explanation = response.choices[0].message.content.strip()

        if session_id:
            session_memory.add_turn(session_id, "user", query)
            session_memory.add_turn(session_id, "assistant", explanation)

        return explanation

    except asyncio.TimeoutError:
        log.warning("LLM timeout", extra={"ctx_session": session_id})
        return _TIMEOUTS.get(language, _TIMEOUTS["en"])
    except Exception as e:
        log.error(f"Groq LLM error: {e}", extra={"ctx_session": session_id})
        return _FALLBACKS.get(language, _FALLBACKS["en"])
