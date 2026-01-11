import 'dart:async';
import '../../../core/transcription/whisper_bridge.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import 'audio_chunker.dart';

class MeetingTranscriptionProcessor {
  final WhisperBridge _whisperBridge;
  final String _language;

  MeetingTranscriptionProcessor({
    required String language,
  }) : _language = language, _whisperBridge = WhisperBridge();

  Future<MeetingTranscriptionResult> processChunks({
    required List<AudioChunk> chunks,
    required AppLocalizations l10n,
    required Function(int processed, int total) onProgress,
  }) async {
    await _whisperBridge.init();

    final StringBuffer buffer = StringBuffer();
    final List<String> inaudibleSegments = [];
    int successfulChunks = 0;

    for (int i = 0; i < chunks.length; i++) {
      try {
        final text = await _whisperBridge.transcribe(
          chunks[i].samples,
          _language,
        );

        if (text.trim().isNotEmpty) {
          buffer.write(text);
          buffer.write(' ');
          successfulChunks++;
        } else {
          buffer.write(l10n.inaudible);
          buffer.write(' ');
          inaudibleSegments.add('Chunk ${i + 1}: Empty response');
        }
      } catch (e) {
        buffer.write(l10n.inaudible);
        buffer.write(' ');
        inaudibleSegments.add('Chunk ${i + 1}: $e');
      }

      onProgress(i + 1, chunks.length);
    }

    final qualityPercentage = (successfulChunks / chunks.length * 100).round();

    return MeetingTranscriptionResult(
      fullText: buffer.toString().trim(),
      inaudibleSegments: inaudibleSegments,
      totalChunks: chunks.length,
      successfulChunks: successfulChunks,
      qualityPercentage: qualityPercentage,
    );
  }
}

class MeetingTranscriptionResult {
  final String fullText;
  final List<String> inaudibleSegments;
  final int totalChunks;
  final int successfulChunks;
  final int qualityPercentage;

  MeetingTranscriptionResult({
    required this.fullText,
    required this.inaudibleSegments,
    required this.totalChunks,
    required this.successfulChunks,
    required this.qualityPercentage,
  });

  String generateMetadata({
    required Duration recordingDuration,
    required DateTime startTime,
    required DateTime endTime,
    required AppLocalizations l10n,
  }) {
    final durationStr = _formatDuration(recordingDuration);

    return '''---
${l10n.meetingMetadataTitle}
${l10n.meetingDuration}: $durationStr
${l10n.meetingChunks}: $totalChunks
${l10n.meetingQuality}: $qualityPercentage%
''';
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    return '${date.day}/${date.month}/${date.year} ${_formatTime(date)}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
