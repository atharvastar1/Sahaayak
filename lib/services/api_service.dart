import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  // Use 10.0.2.2 for Android Emulator, 127.0.0.1 for iOS/Desktop
  // Use 10.0.2.2 for Android Emulator, localhost for Web/iOS
  final String _baseUrl = const bool.fromEnvironment('dart.library.html') 
    ? 'http://localhost:8000' 
    : 'http://10.0.2.2:8000';

  /// Process text query through the backend pipeline (Normalization + Matching)
  Future<AIResponse> processVoice(String text, {String language = 'en'}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/process'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'text': text,
        'language': language,
      }),
    );

    if (response.statusCode == 200) {
      return AIResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to process message: ${response.body}');
    }
  }

  /// Sends audio file to backend for STT
  Future<String> uploadAudio(String filePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/stt'));
    request.files.add(await http.MultipartFile.fromPath('audio', filePath));
    
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['text'];
    } else {
      throw Exception('Failed to convert speech to text');
    }
  }

  /// Gets TTS audio URL for the response message
  Future<String> getSpeech(String text) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/tts'),
      body: {'text': text},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['audio_url'];
    } else {
      throw Exception('Failed to get speech synthesis');
    }
  }

  Future<void> sendFeedback(String requestId, int rating) async {
    // In a real app, this would be a POST to /feedback
    // debug: print('✅ Feedback Sent to Backend | ID: $requestId | Rating: $rating');
  }
}

