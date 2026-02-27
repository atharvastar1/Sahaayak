import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class RecordingService {
  final _audioRecorder = AudioRecorder();
  String? _currentPath;

  Future<bool> startRecording() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) return false;

    try {
      final directory = await getTemporaryDirectory();
      final fileName = 'rec_${const Uuid().v4()}.m4a';
      _currentPath = '${directory.path}/$fileName';

      const config = RecordConfig(); // Default m4a/aac is widely supported
      await _audioRecorder.start(config, path: _currentPath!);
      debugPrint('🎙️ Recording successfully started at: $_currentPath');
      return true;
    } catch (e) {
      debugPrint('❌ Error starting recording: $e');
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      return path;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      return null;
    }
  }

  Future<void> dispose() async {
    await _audioRecorder.dispose();
  }
}
