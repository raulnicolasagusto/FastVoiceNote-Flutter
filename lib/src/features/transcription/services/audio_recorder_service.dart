import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import '../../../core/transcription/whisper_bridge.dart';

class AudioRecorderService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final WhisperBridge _whisperBridge = WhisperBridge();
  String? _currentPath;

  Future<void> init() async {
    await _whisperBridge.init();
  }

  Future<bool> startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      final appDir = await getApplicationDocumentsDirectory();
      _currentPath = '${appDir.path}/temp_recording.pcm';

      // Config: Raw PCM, 16-bit, 16000Hz (Whisper native), Mono
      const config = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        bitRate: 128000,
        sampleRate: 16000,
        numChannels: 1,
      );

      await _audioRecorder.start(config, path: _currentPath!);
      return true;
    }
    return false;
  }

  Future<String?> stopAndTranscribe() async {
    final path = await _audioRecorder.stop();
    if (path == null) return null;

    final file = File(path);
    if (!await file.exists()) return null;

    final bytes = await file.readAsBytes();

    // Convert Int16 (bytes) to Float32 (-1.0 to 1.0)
    // 2 bytes per sample (16-bit)
    final numSamples = bytes.length ~/ 2;
    final samples = Float32List(numSamples);
    final data = bytes.buffer.asByteData();

    for (int i = 0; i < numSamples; i++) {
      final sample = data.getInt16(i * 2, Endian.little);
      // Normalize to -1.0 to 1.0
      samples[i] = sample / 32768.0;
    }

    // Pass to bridge
    // Use Isolate.run for processing to avoid freezing UI in production
    // For now direct call as per simplicity
    final text = await _whisperBridge.transcribe(samples);

    // Cleanup
    await file.delete();
    return text.isEmpty ? null : text;
  }

  Future<void> cancel() async {
    await _audioRecorder.stop();
    if (_currentPath != null) {
      final file = File(_currentPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  void dispose() {
    _audioRecorder.dispose();
    _whisperBridge.dispose();
  }
}
