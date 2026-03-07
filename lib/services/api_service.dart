import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

// [N5 FIX] Generate a unique session ID once per app lifecycle
String _generateSessionId() {
  final now = DateTime.now().millisecondsSinceEpoch;
  final rand = (now * 1103515245 + 12345) & 0x7FFFFFFF;
  return 'flutter-${now.toRadixString(16)}-${rand.toRadixString(16)}';
}

class ApiService {
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  // [N5 FIX] Unique session ID generated once per app launch
  final String sessionId = _generateSessionId();

  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web
  final String _baseUrl = const bool.fromEnvironment('dart.library.html')
      ? 'http://localhost:8000'
      : 'http://10.0.2.2:8000';

  static const String _apiKey = 'PROTOTYPE_MASTER_KEY';

  /// [C2 FIX] Calls /chat with correct production schema.
  /// Sends language_hint so backend responds in the user's chosen language.
  Future<AIResponse> processVoice(String text, {String language = 'en'}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat'),
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': _apiKey,
      },
      body: jsonEncode({
        'message': text,
        'session_id': sessionId,
        'language_hint': language, // [C2 FIX]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Map the production /chat response schema → AIResponse model
      final schemes = (data['schemes'] as List? ?? []).map((s) => Scheme(
        id: s['scheme_id'] ?? '',
        name: s['scheme_name'] ?? '',
        description: s['benefits'] ?? '',
        eligibility: s['eligibility'] ?? '',
        benefits: s['benefits'] ?? '',
        category: s['category'],
      )).toList();

      return AIResponse(
        requestId: data['request_id'] ?? '',
        detectedDialect: data['language_detected'] ?? language,
        normalizedText: text, // [M4 FIX] keep original user text
        aiMessage: data['text'] ?? '',
        suggestedSchemes: schemes,
        audioUrl: data['audio_base64'] != null
            ? 'base64:${data['audio_base64']}'
            : null,
      );
    } else {
      throw Exception('Failed to process message: ${response.body}');
    }
  }

  /// Sends audio file to backend for STT (Whisper)
  Future<Map<String, String>> uploadAudio(String filePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/stt'));
    request.headers['X-API-Key'] = _apiKey;
    request.files.add(await http.MultipartFile.fromPath('audio', filePath));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'text': data['text'] as String,
        'language': data['detected_language'] as String,
      };
    } else {
      throw Exception('Failed to convert speech to text');
    }
  }

  Future<void> sendFeedback(String requestId, int rating) async {
    // Feedback endpoint — future implementation
  }
}
