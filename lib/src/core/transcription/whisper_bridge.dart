import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

typedef InitWhisperFunc = Int32 Function(Pointer<Utf8>);
typedef InitWhisper = int Function(Pointer<Utf8>);

typedef TranscribeFunc = Pointer<Utf8> Function(Pointer<Float>, Int32);
typedef Transcribe = Pointer<Utf8> Function(Pointer<Float>, int);

typedef FreeWhisperFunc = Void Function();
typedef FreeWhisper = void Function();

class WhisperBridge {
  static final WhisperBridge _instance = WhisperBridge._internal();
  factory WhisperBridge() => _instance;
  WhisperBridge._internal();

  DynamicLibrary? _lib;
  late InitWhisper _initWhisper;
  late Transcribe _transcribe;
  late FreeWhisper _freeWhisper;

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      if (Platform.isAndroid) {
        _lib = DynamicLibrary.open('libwhisper.so');
      } else if (Platform.isIOS) {
        _lib = DynamicLibrary.process();
      } else {
        throw UnsupportedError('Unsupported platform');
      }

      _initWhisper = _lib!.lookupFunction<InitWhisperFunc, InitWhisper>(
        'native_init_whisper',
      );
      _transcribe = _lib!.lookupFunction<TranscribeFunc, Transcribe>(
        'native_transcribe',
      );
      _freeWhisper = _lib!.lookupFunction<FreeWhisperFunc, FreeWhisper>(
        'native_free_whisper',
      );

      await _loadModel();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing Whisper: $e');
      rethrow;
    }
  }

  Future<void> _loadModel() async {
    // Copy model from assets to local storage if needed
    final appDir = await getApplicationDocumentsDirectory();
    final modelPath = '${appDir.path}/model.bin';
    final modelFile = File(modelPath);

    if (!await modelFile.exists()) {
      print('Copying model to $modelPath');
      try {
        final byteData = await rootBundle.load(
          'assets/models/ggml-base-q5_1.bin',
        ); // User's specific file
        final buffer = byteData.buffer;
        await modelFile.writeAsBytes(
          buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        );
      } catch (e) {
        // Fallback or better error handling
        print(
          'Error copying model: $e check if assets/models/ggml-base-q5_1.bin exists',
        );
        // Try generic name if specific fails? No, fail hard to debug.
        throw Exception(
          'Model file not found in assets. Did you put ggml-base-q5_1.bin in assets/models/?',
        );
      }
    }

    final pathPtr = modelPath.toNativeUtf8();
    final result = _initWhisper(pathPtr);
    calloc.free(pathPtr);

    if (result != 0) {
      throw Exception('Failed to initialize Whisper native context');
    }
  }

  Future<String> transcribe(List<double> samples) async {
    if (!_isInitialized) {
      await init();
    }

    // Convert List<double> to Pointer<Float>
    final pointer = calloc<Float>(samples.length);
    final buffer = pointer.asTypedList(samples.length);
    for (int i = 0; i < samples.length; i++) {
      buffer[i] = samples[i];
    }

    // Run in compute/isolate to avoid blocking UI?
    // FFI calls are synchronous on the calling thread.
    // Ideally this should be in an isolate or use FFI non-blocking if available (experimental).
    // For now, simple await, but typically FFI blocks standard isolates.
    // We will assume short audio bits or tolerant UI.
    // To fix blocking content, we should use Isolate.run() in Dart 3.

    // BUT: passing pointers between isolates is tricky without simple addresses.
    // We'll wrap this call logic later in service if UI freezes.

    final resultPtr = _transcribe(pointer, samples.length);
    final result = resultPtr.toDartString();

    // We don't free resultPtr as it is static/thread_local in C++ simplification.
    calloc.free(pointer);

    return result;
  }

  void dispose() {
    if (_isInitialized) {
      _freeWhisper();
      _isInitialized = false;
    }
  }
}
