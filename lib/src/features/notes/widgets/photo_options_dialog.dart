import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/l10n/generated/app_localizations.dart';

class PhotoOptionsDialog extends StatelessWidget {
  final VoidCallback? onTakePhoto;
  final VoidCallback? onUploadFile;
  final VoidCallback? onDrawing;

  const PhotoOptionsDialog({
    super.key,
    this.onTakePhoto,
    this.onUploadFile,
    this.onDrawing,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? colors.surface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              l10n.addMedia,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? colors.onSurface : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            // Options List
            _OptionItem(
              icon: Icons.camera_alt,
              label: l10n.takePicture,
              isDark: isDark,
              onTap: () {
                Navigator.of(context).pop();
                onTakePhoto?.call();
              },
            ),
            const SizedBox(height: 16),
            _OptionItem(
              icon: Icons.upload_file,
              label: l10n.uploadFile,
              isDark: isDark,
              onTap: () {
                Navigator.of(context).pop();
                onUploadFile?.call();
              },
            ),
            const SizedBox(height: 16),
            _OptionItem(
              icon: Icons.palette_outlined,
              label: l10n.drawing,
              isDark: isDark,
              onTap: () {
                Navigator.of(context).pop();
                onDrawing?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _OptionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textColor = isDark ? colors.onSurface : Colors.black87;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
