class AudioChunker {
  static const Duration chunkDuration = Duration(seconds: 20);
  static const Duration overlapDuration = Duration(seconds: 2);

  static List<AudioChunk> chunkAudio({
    required List<double> samples,
    required int sampleRate,
  }) {
    final chunkSize = sampleRate * chunkDuration.inSeconds;
    final overlapSize = sampleRate * overlapDuration.inSeconds;
    final stepSize = chunkSize - overlapSize;

    final List<AudioChunk> chunks = [];
    int startSample = 0;
    int chunkIndex = 0;

    while (startSample + chunkSize <= samples.length) {
      final endSample = startSample + chunkSize;
      final chunkSamples = samples.sublist(startSample, endSample);

      chunks.add(AudioChunk(
        index: chunkIndex,
        startSample: startSample,
        samples: chunkSamples,
      ));

      startSample += stepSize;
      chunkIndex++;
    }

    if (startSample < samples.length) {
      final finalChunkSize = samples.length - startSample;
      if (finalChunkSize >= (sampleRate * 5)) {
        chunks.add(AudioChunk(
          index: chunkIndex,
          startSample: startSample,
          samples: samples.sublist(startSample),
        ));
      }
    }

    return chunks;
  }
}

class AudioChunk {
  final int index;
  final int startSample;
  final List<double> samples;

  AudioChunk({
    required this.index,
    required this.startSample,
    required this.samples,
  });
}
