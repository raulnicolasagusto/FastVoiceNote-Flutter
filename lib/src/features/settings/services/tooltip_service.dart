import 'package:flutter/material.dart';

/// Service to manage tooltips shown to users
class TooltipService {
  /// Show a tooltip above a widget
  void showTooltip({
    required BuildContext context,
    required GlobalKey targetKey,
    required String message,
    required Function(bool wasManual) onDismiss,
    Duration duration = const Duration(seconds: 6),
  }) {
    // Get the RenderBox of the target widget
    final RenderBox? renderBox = 
        targetKey.currentContext?.findRenderObject() as RenderBox?;
    
    if (renderBox == null) {
      onDismiss(false); // false = failed to show, not manually dismissed
      return;
    }
    
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _TooltipOverlay(
        targetOffset: offset,
        targetSize: size,
        message: message,
        onDismiss: (bool wasManual) {
          overlayEntry.remove();
          onDismiss(wasManual);
        },
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Auto-dismiss after duration
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
        onDismiss(false); // false = auto-dismissed, not manual
      }
    });
  }
}

/// Overlay widget to show tooltip
class _TooltipOverlay extends StatelessWidget {
  final Offset targetOffset;
  final Size targetSize;
  final String message;
  final Function(bool wasManual) onDismiss;
  
  const _TooltipOverlay({
    required this.targetOffset,
    required this.targetSize,
    required this.message,
    required this.onDismiss,
  });
  
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate tooltip position - place it below the target for better visibility
    final tooltipTop = targetOffset.dy + targetSize.height + 12; // Position below with some spacing
    
    // Make sure tooltip doesn't go off screen
    final safeTop = tooltipTop.clamp(60.0, screenHeight - 200);
    
    return Stack(
      children: [
        // Semi-transparent background
        GestureDetector(
          onTap: () => onDismiss(true), // true = manually dismissed
          child: Container(
            color: Colors.black.withValues(alpha: 0.3),
          ),
        ),
        // Arrow pointing to target (above the tooltip)
        Positioned(
          top: safeTop - 10,
          left: targetOffset.dx + (targetSize.width / 2) - 10,
          child: CustomPaint(
            size: const Size(20, 10),
            painter: _TrianglePainter(),
          ),
        ),
        // Tooltip
        Positioned(
          top: safeTop,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => onDismiss(true), // true = manually dismissed
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the arrow
class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;
    
    final path = Path();
    // Triangle pointing up
    path.moveTo(size.width / 2, 0); // Top center
    path.lineTo(0, size.height);     // Bottom left
    path.lineTo(size.width, size.height); // Bottom right
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
