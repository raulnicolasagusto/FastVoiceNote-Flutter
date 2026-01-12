import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

class RichTextUtils {
  static const String richTextPrefix = 'RICH_TEXT_DELTA:';

  /// Check if the content is rich text (Delta format)
  static bool isRichText(String content) {
    return content.startsWith(richTextPrefix);
  }

  /// Convert plain text to Delta JSON string with prefix
  static String plainToRich(String text) {
    if (text.isEmpty) {
      return '$richTextPrefix${jsonEncode(Delta().toJson())}';
    }

    final delta = Delta();
    final lines = text.split('\n');
    for (var i = 0; i < lines.length; i++) {
      delta.insert(lines[i]);
      delta.insert('\n');
    }

    final json = jsonEncode(delta.toJson());
    return '$richTextPrefix$json';
  }

  /// Get plain text from rich text content (for search or previews)
  static String getPlainText(String content) {
    if (!isRichText(content)) return content;

    try {
      final jsonString = content.substring(richTextPrefix.length);
      final json = jsonDecode(jsonString) as List;
      final delta = Delta.fromJson(json);
      final document = Document.fromDelta(delta);
      return document.toPlainText();
    } catch (e) {
      return content;
    }
  }

  /// Get Delta from content string
  static Delta getDelta(String content) {
    if (!isRichText(content)) {
      return Delta()
        ..insert(content)
        ..insert('\n');
    }

    try {
      final jsonString = content.substring(richTextPrefix.length);
      final json = jsonDecode(jsonString) as List;
      return Delta.fromJson(json);
    } catch (e) {
      final delta = Delta();
      final lines = content.split('\n');
      for (var i = 0; i < lines.length; i++) {
        delta.insert(lines[i]);
        delta.insert('\n');
      }
      return delta;
    }
  }

  /// Convert Delta to storage string with prefix
  static String deltaToStorage(Delta delta) {
    final json = jsonEncode(delta.toJson());
    return '$richTextPrefix$json';
  }
}
