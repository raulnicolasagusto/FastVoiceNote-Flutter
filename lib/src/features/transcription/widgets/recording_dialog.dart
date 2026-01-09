import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/l10n/generated/app_localizations.dart';

class RecordingDialog extends StatefulWidget {
  final VoidCallback onStop;
  final VoidCallback onCancel;

  const RecordingDialog({
    super.key,
    required this.onStop,
    required this.onCancel,
  });

  @override
  State<RecordingDialog> createState() => _RecordingDialogState();
}

class _RecordingDialogState extends State<RecordingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleStop() async {
    setState(() {
      _isProcessing = true;
    });
    widget.onStop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Waveform visualizer or Processing text
            SizedBox(
              height: 48,
              child: _isProcessing
                  ? Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '⏳',
                            style: TextStyle(fontSize: 32),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.processing,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2196F3),
                            ),
                          ),
                        ],
                      ),
                    )
                  : AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final height =
                                16.0 +
                                (32.0 *
                                    (0.5 +
                                        0.5 *
                                            _controller.value *
                                            ((index % 2 == 0) ? 1 : -1)));
                            return Container(
                              width: 6,
                              height: height,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53935).withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: _isProcessing ? null : widget.onCancel,
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: Text(
                      l10n.cancel,
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: _isProcessing 
                          ? const Color(0xFF78909C).withValues(alpha: 0.5)
                          : const Color(0xFF78909C),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextButton.icon(
                    onPressed: _isProcessing ? null : _handleStop,
                    icon: _isProcessing 
                        ? const Icon(Icons.hourglass_bottom, color: Colors.white)
                        : const Icon(Icons.check, color: Colors.white),
                    label: Text(
                      _isProcessing ? l10n.processing : 'Stop',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: _isProcessing 
                          ? const Color(0xFF43A047).withValues(alpha: 0.7)
                          : const Color(0xFF43A047),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
