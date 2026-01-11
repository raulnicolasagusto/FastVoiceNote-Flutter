import 'dart:async';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'dart:io';

class MeetingRecorderService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  Timer? _maxDurationTimer;
  String? _currentPath;
  DateTime? _recordingStartTime;
  bool _autoStopped = false;

  Future<bool> startMeetingRecording() async {
    if (await Permission.microphone.request().isGranted) {
      final appDir = await getApplicationDocumentsDirectory();
      _currentPath = '${appDir.path}/meeting_${DateTime.now().millisecondsSinceEpoch}.pcm';
      _recordingStartTime = DateTime.now();

      const config = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        bitRate: 128000,
        sampleRate: 16000,
        numChannels: 1,
      );

      await _audioRecorder.start(config, path: _currentPath!);

      _maxDurationTimer = Timer(const Duration(hours: 1), () {
        _autoStopped = true;
      });

      return true;
    }
    return false;
  }

  Future<MeetingRecordingResult?> stopRecording() async {
    _maxDurationTimer?.cancel();
    final endTime = DateTime.now();

    final path = await _audioRecorder.stop();
    if (path == null) return null;

    final file = File(path);
    if (!await file.exists()) {
      await file.delete();
      return null;
    }

    final bytes = await file.readAsBytes();

    final numSamples = bytes.length ~/ 2;
    final samples = Float32List(numSamples);
    final data = bytes.buffer.asByteData();

    for (int i = 0; i < numSamples; i++) {
      final sample = data.getInt16(i * 2, Endian.little);
      samples[i] = sample / 32768.0;
    }

    final duration = endTime.difference(_recordingStartTime!);

    await file.delete();

    return MeetingRecordingResult(
      samples: samples,
      startTime: _recordingStartTime!,
      endTime: endTime,
      duration: duration,
      autoStopped: _autoStopped,
    );
  }

  Future<void> cancel() async {
    _maxDurationTimer?.cancel();
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
    _maxDurationTimer?.cancel();
  }
}

class MeetingRecordingResult {
  final List<double> samples;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final bool autoStopped;

  MeetingRecordingResult({
    required this.samples,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.autoStopped,
  });
}
