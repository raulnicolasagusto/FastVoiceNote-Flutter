import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoteCard extends StatelessWidget {
  final String title;
  final DateTime date;
  final String content;
  final Color color;
  final bool hasImage;
  final bool hasVoice;
  final bool isSelected;
  final bool isPinned;

  const NoteCard({
    super.key,
    required this.title,
    required this.date,
    required this.content,
    required this.color,
    this.hasImage = false,
    this.hasVoice = false,
    this.isSelected = false,
    this.isPinned = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine text color based on background luminance
    final textColor = color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
    final subtitleColor = color.computeLuminance() > 0.5 
        ? Colors.grey[700]! 
        : Colors.white.withValues(alpha: 0.7);
    final iconColor = color.computeLuminance() > 0.5 
        ? Colors.grey[600]! 
        : Colors.white.withValues(alpha: 0.8);
    
    return Stack(
      children: [
        Card(
          color: color,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.edit, size: 16, color: iconColor),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(date),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: subtitleColor),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: textColor),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasImage || hasVoice) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (hasImage)
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(Icons.image, size: 20, color: Colors.purple),
                        ),
                      if (hasVoice)
                        const Icon(Icons.mic, size: 20, color: Colors.orange),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        if (isPinned)
          Positioned(
            top: 10,
            left: 10,
            child: Icon(
              Icons.star,
              color: Colors.amber,
              size: 20,
            ),
          ),
        if (isSelected)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF2196F3),
                size: 20,
              ),
            ),
          ),
      ],
    );
  }
}
