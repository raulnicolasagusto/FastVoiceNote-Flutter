import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

typedef InitWhisperFunc = Int32 Function(Pointer<Utf8>);
typedef InitWhisper = int Function(Pointer<Utf8>);

// Updated typedef to include language parameter
typedef TranscribeFunc = Pointer<Utf8> Function(Pointer<Float>, Int32, Pointer<Utf8>);
typedef Transcribe = Pointer<Utf8> Function(Pointer<Float>, int, Pointer<Utf8>);

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
          'assets/models/ggml-tiny-q5_1.bin',
        ); // Tiny model - faster, less accurate
        final buffer = byteData.buffer;
        await modelFile.writeAsBytes(
          buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        );
      } catch (e) {
        // Fallback or better error handling
        print(
          'Error copying model: $e check if assets/models/ggml-tiny-q5_1.bin exists',
        );
        // Try generic name if specific fails? No, fail hard to debug.
        throw Exception(
          'Model file not found in assets. Did you put ggml-tiny-q5_1.bin in assets/models/?',
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

  Future<String> transcribe(List<double> samples, [String language = 'en']) async {
    if (!_isInitialized) {
      await init();
    }

    // Convert List<double> to Pointer<Float>
    final pointer = calloc<Float>(samples.length);
    final buffer = pointer.asTypedList(samples.length);
    for (int i = 0; i < samples.length; i++) {
      buffer[i] = samples[i];
    }

    // Convert language code to Whisper format
    // es -> Spanish, pt -> Portuguese, en -> English
    String whisperLanguage = _mapToWhisperLanguage(language);
    print('Transcribing with language: $whisperLanguage');

    // Convert language string to UTF-8 pointer
    final languagePtr = whisperLanguage.toNativeUtf8();

    // Call native function with language parameter
    final resultPtr = _transcribe(pointer, samples.length, languagePtr);
    final result = resultPtr.toDartString();

    // Free allocated memory
    calloc.free(pointer);
    calloc.free(languagePtr);

    return result;
  }

  String _mapToWhisperLanguage(String language) {
    // Map language codes to Whisper format
    // Flutter locale codes are typically 'es', 'pt', 'en'
    // Whisper accepts full language names like 'spanish', 'portuguese', 'english'
    switch (language.toLowerCase()) {
      case 'es':
      case 'spanish':
        return 'spanish';
      case 'pt':
      case 'portuguese':
        return 'portuguese';
      case 'en':
      case 'english':
      default:
        return 'english';
    }
  }

  void dispose() {
    if (_isInitialized) {
      _freeWhisper();
      _isInitialized = false;
    }
  }
}
