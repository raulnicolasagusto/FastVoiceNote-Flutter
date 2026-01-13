import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/note_block.dart';
import '../../views/image_preview_screen.dart';

class ImageBlockWidget extends StatelessWidget {
  final ImageBlock block;
  final VoidCallback onDelete;
  final VoidCallback onTranscribe;

  const ImageBlockWidget({
    super.key,
    required this.block,
    required this.onDelete,
    required this.onTranscribe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ImagePreviewScreen(
                    imagePath: block.imagePath,
                    heroTag: 'block_${block.id}',
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Hero(
                tag: 'block_${block.id}',
                child: Image.file(
                  File(block.imagePath),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text('Image not found'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Delete Button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 20, color: Colors.white),
              ),
            ),
          ),
          // Transcribe Button
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: onTranscribe,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.text_fields, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'TRANSCRIBE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
