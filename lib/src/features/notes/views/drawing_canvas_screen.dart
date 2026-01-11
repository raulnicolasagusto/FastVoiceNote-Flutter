import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../core/l10n/generated/app_localizations.dart';

class DrawingCanvasScreen extends StatefulWidget {
  const DrawingCanvasScreen({super.key});

  @override
  State<DrawingCanvasScreen> createState() => _DrawingCanvasScreenState();
}

class _DrawingCanvasScreenState extends State<DrawingCanvasScreen> {
  List<DrawingPoint?> points = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 5.0;
  bool isEraser = false;
  List<List<DrawingPoint?>> history = []; // Simple undo/redo
  List<List<DrawingPoint?>> redoHistory = [];

  void _saveCurrentToHistory() {
    history.add(List.from(points));
    redoHistory.clear();
  }

  void _undo() {
    if (history.isNotEmpty) {
      setState(() {
        redoHistory.add(List.from(points));
        points = history.removeLast();
      });
    }
  }

  void _redo() {
    if (redoHistory.isNotEmpty) {
      setState(() {
        history.add(List.from(points));
        points = redoHistory.removeLast();
      });
    }
  }

  Future<void> _saveDrawing() async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final size = const Size(1000, 1000); // Fixed size for saving

      // Create a layer for the eraser to work with BlendMode.clear
      canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

      // Draw background
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white,
      );

      final double scale = 1000 / MediaQuery.of(context).size.width;

      for (int i = 0; i < points.length - 1; i++) {
        if (points[i] != null && points[i + 1] != null) {
          final paint = Paint()
            ..color = points[i]!.paint.color
            ..strokeCap = points[i]!.paint.strokeCap
            ..strokeWidth = points[i]!.paint.strokeWidth * scale
            ..style = points[i]!.paint.style
            ..blendMode = points[i]!.paint.blendMode;

          canvas.drawLine(
            points[i]!.offset * scale,
            points[i + 1]!.offset * scale,
            paint,
          );
        }
      }
      canvas.restore();

      final picture = recorder.endRecording();
      final img = await picture.toImage(1000, 1000);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final String fileName =
          'drawing_${DateTime.now().millisecondsSinceEpoch}.png';
      final String filePath = p.join(directory.path, fileName);

      final File file = File(filePath);
      await file.writeAsBytes(pngBytes);

      if (mounted) {
        Navigator.of(context).pop(filePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving drawing: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(
        title: Text(
          l10n.drawingStudio,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: history.isNotEmpty ? _undo : null,
            tooltip: l10n.undo,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: redoHistory.isNotEmpty ? _redo : null,
            tooltip: l10n.redo,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveDrawing,
            tooltip: l10n.save,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: GestureDetector(
                onPanStart: (details) {
                  _saveCurrentToHistory();
                  setState(() {
                    points.add(
                      DrawingPoint(
                        offset: details.localPosition,
                        paint: Paint()
                          ..color = isEraser
                              ? Colors.transparent
                              : selectedColor
                          ..strokeCap = StrokeCap.round
                          ..strokeWidth = strokeWidth
                          ..blendMode = isEraser
                              ? BlendMode.clear
                              : BlendMode.srcOver,
                      ),
                    );
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    points.add(
                      DrawingPoint(
                        offset: details.localPosition,
                        paint: Paint()
                          ..color = isEraser
                              ? Colors.transparent
                              : selectedColor
                          ..strokeCap = StrokeCap.round
                          ..strokeWidth = strokeWidth
                          ..blendMode = isEraser
                              ? BlendMode.clear
                              : BlendMode.srcOver,
                      ),
                    );
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    points.add(null);
                  });
                },
                child: CustomPaint(
                  painter: CanvasPainter(points: points),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
          _buildToolbar(context, l10n, colors),
        ],
      ),
    );
  }

  Widget _buildToolbar(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colors,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: Theme.of(context).cardColor,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.line_weight, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: strokeWidth,
                    min: 1,
                    max: 40,
                    onChanged: (val) => setState(() => strokeWidth = val),
                  ),
                ),
                Text(
                  strokeWidth.round().toString(),
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ToolbarItem(
                  icon: Icons.brush,
                  label: l10n.brush,
                  isSelected: !isEraser,
                  onTap: () => setState(() => isEraser = false),
                ),
                _ToolbarItem(
                  icon: Icons.auto_fix_normal,
                  label: l10n.eraser,
                  isSelected: isEraser,
                  onTap: () => setState(() => isEraser = true),
                ),
                _ToolbarItem(
                  icon: Icons.palette,
                  label: l10n.colors,
                  isSelected: false,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: BlockPicker(
                          pickerColor: selectedColor,
                          onColorChanged: (color) {
                            setState(() {
                              selectedColor = color;
                              isEraser = false;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                ),
                _ToolbarItem(
                  icon: Icons.delete_outline,
                  label: l10n.deleteConfirm,
                  isSelected: false,
                  onTap: () {
                    _saveCurrentToHistory();
                    setState(() => points.clear());
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToolbarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? colors.primary : Colors.grey,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isSelected ? colors.primary : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawingPoint {
  Offset offset;
  Paint paint;
  DrawingPoint({required this.offset, required this.paint});
}

class CanvasPainter extends CustomPainter {
  List<DrawingPoint?> points;
  CanvasPainter({required this.points});

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(
          points[i]!.offset,
          points[i + 1]!.offset,
          points[i]!.paint,
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
