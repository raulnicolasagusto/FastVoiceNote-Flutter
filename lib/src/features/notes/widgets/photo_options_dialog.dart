import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PhotoOptionsDialog extends StatelessWidget {
  final VoidCallback? onTakePhoto;
  final VoidCallback? onUploadFile;

  const PhotoOptionsDialog({
    super.key,
    this.onTakePhoto,
    this.onUploadFile,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? colors.surface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Add Media',
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
              label: 'Take a picture',
              isDark: isDark,
              onTap: () {
                Navigator.of(context).pop();
                onTakePhoto?.call();
              },
            ),
            const SizedBox(height: 16),
            _OptionItem(
              icon: Icons.upload_file,
              label: 'Upload a picture or file',
              isDark: isDark,
              onTap: () {
                Navigator.of(context).pop();
                onUploadFile?.call();
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
            Icon(
              icon,
              color: textColor,
              size: 24,
            ),
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
