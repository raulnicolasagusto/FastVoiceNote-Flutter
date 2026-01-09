import 'dart:async';

/// Global intent handler for quick voice note triggered from app shortcuts
class QuickVoiceNoteIntent {
  static final _controller = StreamController<void>.broadcast();
  
  static Stream<void> get stream => _controller.stream;
  
  static void trigger() {
    _controller.add(null);
  }
  
  static void dispose() {
    _controller.close();
  }
}
