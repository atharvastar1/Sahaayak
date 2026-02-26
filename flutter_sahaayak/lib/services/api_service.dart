import '../models/models.dart';
import 'local_engine.dart';

/// [ApiService] now serves as a local bridge to the [LocalEngine].
///
/// By using a local engine, the app is 100% Flutter and requires no
/// external server or other languages to run.
class ApiService {
  // --- Private Constructor for Singleton ---
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final LocalEngine _engine = LocalEngine();

  /// Processes voice input locally using the Dart-ported Neural Engine.
  Future<AIResponse> processVoice(String text, {String language = 'en'}) async {
    return _engine.processVoice(text);
  }

  /// Locally simulates feedback submission.
  Future<void> sendFeedback(String requestId, int rating) async {
    // In a pure Flutter version, this could be saved to local storage (SQLite/Hive)
    print('✅ Feedback Saved Locally | ID: $requestId | Rating: $rating');
  }
}
