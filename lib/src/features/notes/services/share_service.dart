import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../widgets/note_card_widget.dart';

class ShareService {
  final ScreenshotController _screenshotController = ScreenshotController();

  /// Share a note as an image
  Future<void> shareNoteAsImage({
    required BuildContext context,
    required String title,
    required String content,
    required Color noteColor,
  }) async {
    try {
      // Create the note card widget
      final noteCard = NoteCardWidget(
        title: title,
        content: content,
        noteColor: noteColor,
      );

      // Wrap in MaterialApp to have proper context for localization
      final widgetToCapture = MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Localizations.localeOf(context),
        home: Material(
          color: const Color(0xFFF5F1E8),
          child: noteCard,
        ),
      );

      // Capture the widget as image
      final Uint8List? imageBytes = await _screenshotController.captureFromWidget(
        widgetToCapture,
        context: context,
        pixelRatio: 3.0, // High quality
      );

      if (imageBytes == null) {
        throw Exception('Failed to capture image');
      }

      // Show preview dialog
      if (context.mounted) {
        final shouldShare = await showDialog<bool>(
          context: context,
          builder: (context) => _ImagePreviewDialog(imageBytes: imageBytes),
        );

        if (shouldShare != true) {
          return; // User cancelled
        }
      }

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/note_$timestamp.png');
      await file.writeAsBytes(imageBytes);

      // Share the image
      await Share.shareXFiles(
        [XFile(file.path)],
        text: title.isNotEmpty ? title : 'Note',
      );

      // Clean up temporary file after a delay
      Future.delayed(const Duration(seconds: 5), () {
        if (file.existsSync()) {
          file.deleteSync();
        }
      });
    } catch (e) {
      debugPrint('Error sharing note as image: $e');
      rethrow;
    }
  }

  /// Share a note as text
  Future<void> shareNoteAsText({
    required String title,
    required String content,
  }) async {
    try {
      final textToShare = title.isNotEmpty 
          ? '$title\n\n$content'
          : content;

      await Share.share(textToShare);
    } catch (e) {
      debugPrint('Error sharing note as text: $e');
      rethrow;
    }
  }
}

class _ImagePreviewDialog extends StatelessWidget {
  final Uint8List imageBytes;

  const _ImagePreviewDialog({required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Preview image
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(false),
                icon: const Icon(Icons.close),
                label: const Text('Cancel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.share),
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
