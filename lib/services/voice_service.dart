import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class VoiceService {
  static final FlutterTts _flutterTts = FlutterTts();

  static Future<void> init() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  static void speak(String text, String langCode) async {
    debugPrint('VOICE ASSIST ($langCode): $text');
    
    // Set language based on code
    String ttsLang = "en-US";
    if (langCode == 'hi') ttsLang = "hi-IN";
    if (langCode == 'mr') ttsLang = "mr-IN";
    
    await _flutterTts.setLanguage(ttsLang);
    await _flutterTts.speak(text);
  }

  static void announceScreen(String title, String description) {
    speak('Now viewing $title. $description', 'en');
  }
}
