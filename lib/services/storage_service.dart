import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const String _keySchemes = 'cached_schemes';

  Future<void> cacheResponse(AIResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_keySchemes) ?? [];
    history.insert(0, jsonEncode({
      'timestamp': DateTime.now().toIso8601String(),
      'response': response.toJson(), // Need to add toJson to AIResponse
    }));
    // Keep only last 10
    if (history.length > 10) history = history.sublist(0, 10);
    await prefs.setStringList(_keySchemes, history);
  }

  Future<List<AIResponse>> getCachedResponses() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_keySchemes) ?? [];
    return history.map((e) => AIResponse.fromJson(jsonDecode(e)['response'])).toList();
  }
}
