import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'local_engine.dart';
import 'storage_service.dart';

/// The central nervous system for Sahaayak Intelligence.
class AICoordinator {
  final ApiService _cloud = ApiService();
  final LocalEngine _local = LocalEngine();
  final StorageService _storage = StorageService();

  // Toggle this to test cloud vs local algorithms
  static bool isFrontendOnly = true;

  /// Orchestrates reasoning through Cloud or Local channels.
  Future<AIResponse> processQuery(String text, String langCode) async {
    if (isFrontendOnly) {
      debugPrint('AI COORDINATOR: [FRONTEND MODE] Using Local Engine...');
      final response = await _local.processVoice(text, langCode);
      await _storage.cacheResponse(response);
      return response;
    }

    try {
      final response = await _cloud.processVoice(text, language: langCode);
      await _storage.cacheResponse(response);
      return response;
    } catch (e) {
      final response = await _local.processVoice(text, langCode);
      await _storage.cacheResponse(response);
      return response;
    }
  }

  /// Process raw audio through Whisper STT and then the main pipeline
  Future<AIResponse> processAudio(String filePath, String langCode) async {
    if (isFrontendOnly) {
       // Deep Simulation for Frontend Development
       await Future.delayed(const Duration(seconds: 2));
       return await processQuery("Simulated Voice Input", langCode);
    }

    try {
      final sttResult = await _cloud.uploadAudio(filePath);
      return await processQuery(sttResult['text']!, sttResult['language']!);
    } catch (e) {
      debugPrint('AI COORDINATOR ERROR: $e. Falling back to local...');
      return await processQuery("Speech fallback", langCode);
    }
  }

  Future<List<AIResponse>> getInsightHistory() async {
    return await _storage.getCachedResponses();
  }
}
