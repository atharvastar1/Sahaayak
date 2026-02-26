import 'package:flutter/material.dart';

class VoiceService {
  static void speak(String text, String langCode) {
    // In a real app, this would call flutter_tts
    debugPrint('VOICE ASSIST ($langCode): $text');
  }

  static void announceScreen(String title, String description) {
    speak('Now viewing $title. $description', 'en');
  }
}
