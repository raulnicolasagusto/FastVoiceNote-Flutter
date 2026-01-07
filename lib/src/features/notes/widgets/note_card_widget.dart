import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../models/checklist_utils.dart';

class NoteCardWidget extends StatelessWidget {
  final String title;
  final String content;
  final Color noteColor;

  const NoteCardWidget({
    super.key,
    required this.title,
    required this.content,
    required this.noteColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasChecklist = ChecklistUtils.hasChecklist(content);
    
    // Determine text color based on background luminance
    final textColor = noteColor.computeLuminance() > 0.5 
        ? Colors.black87 
        : const Color(0xFF5D4E3C); // Brown color for light backgrounds

    return Container(
      color: const Color(0xFFF5F1E8), // Beige background
      padding: const EdgeInsets.all(40),
      child: Center(
        child: IntrinsicWidth(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 300,
              maxWidth: 600,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Note card with decorative border
                Container(
                  decoration: BoxDecoration(
                    color: noteColor,
                    border: Border.all(
                      color: const Color(0xFFB8A68D), // Border color
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Corner decorations
                      Positioned(
                        top: 0,
                        left: 0,
                        child: _CornerDecoration(),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Transform.rotate(
                          angle: 1.5708, // 90 degrees
                          child: _CornerDecoration(),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Transform.rotate(
                          angle: -1.5708, // -90 degrees
                          child: _CornerDecoration(),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Transform.rotate(
                          angle: 3.14159, // 180 degrees
                          child: _CornerDecoration(),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            if (title.isNotEmpty) ...[
                              Text(
                                title,
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                            // Content
                            if (hasChecklist)
                              _buildChecklistContent(textColor)
                            else
                              Text(
                                content,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: textColor,
                                  height: 1.5,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // "Created with Fast Voice Note" footer
                Text(
                  l10n.createdWithNotes,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistContent(Color textColor) {
    final items = ChecklistUtils.jsonToItems(content);
    final text = ChecklistUtils.getText(content);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Checklist items
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                item.isChecked 
                    ? Icons.check_box 
                    : Icons.check_box_outline_blank,
                color: textColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.text,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: textColor,
                    decoration: item.isChecked 
                        ? TextDecoration.lineThrough 
                        : null,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        )),
        // Additional text below checklist
        if (text.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: textColor,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

class _CornerDecoration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(30, 30),
      painter: _CornerPainter(),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB8A68D)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Outer L shape
    path.moveTo(0, size.height * 0.6);
    path.lineTo(0, 0);
    path.lineTo(size.width * 0.6, 0);
    
    // Inner L shape
    path.moveTo(size.width * 0.2, size.height * 0.4);
    path.lineTo(size.width * 0.2, size.height * 0.2);
    path.lineTo(size.width * 0.4, size.height * 0.2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
