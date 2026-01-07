import 'package:flutter/material.dart';

class ColorPickerModal extends StatelessWidget {
  final Function(String color) onColorSelected;
  final String currentColor;

  const ColorPickerModal({
    super.key,
    required this.onColorSelected,
    required this.currentColor,
  });

  // Soft pastel colors that work in both light and dark modes
  static const List<Map<String, dynamic>> noteColors = [
    {'name': 'Default', 'light': 'FFFFFFFF', 'dark': 'FF1E1E1E'}, // White / Dark grey
    {'name': 'Red', 'light': 'FFFFCDD2', 'dark': 'FFD32F2F'}, // Light red / Red
    {'name': 'Pink', 'light': 'FFF8BBD0', 'dark': 'FFC2185B'}, // Light pink / Pink
    {'name': 'Purple', 'light': 'FFE1BEE7', 'dark': 'FF8E24AA'}, // Light purple / Purple
    {'name': 'Deep Purple', 'light': 'FFD1C4E9', 'dark': 'FF5E35B1'}, // Light deep purple / Deep purple
    {'name': 'Indigo', 'light': 'FFC5CAE9', 'dark': 'FF3949AB'}, // Light indigo / Indigo
    {'name': 'Blue', 'light': 'FFBBDEFB', 'dark': 'FF1E88E5'}, // Light blue / Blue
    {'name': 'Cyan', 'light': 'FFB2EBF2', 'dark': 'FF00ACC1'}, // Light cyan / Cyan
    {'name': 'Teal', 'light': 'FFB2DFDB', 'dark': 'FF00897B'}, // Light teal / Teal
    {'name': 'Green', 'light': 'FFC8E6C9', 'dark': 'FF43A047'}, // Light green / Green
    {'name': 'Light Green', 'light': 'FFDCEDC8', 'dark': 'FF7CB342'}, // Light light green / Light green
    {'name': 'Lime', 'light': 'FFF0F4C3', 'dark': 'FFC0CA33'}, // Light lime / Lime
    {'name': 'Yellow', 'light': 'FFFFF9C4', 'dark': 'FFFDD835'}, // Light yellow / Yellow
    {'name': 'Amber', 'light': 'FFFFECB3', 'dark': 'FFFFB300'}, // Light amber / Amber
    {'name': 'Orange', 'light': 'FFFFE0B2', 'dark': 'FFFB8C00'}, // Light orange / Orange
    {'name': 'Deep Orange', 'light': 'FFFFCCBC', 'dark': 'FFF4511E'}, // Light deep orange / Deep orange
    {'name': 'Brown', 'light': 'FFD7CCC8', 'dark': 'FF6D4C41'}, // Light brown / Brown
    {'name': 'Grey', 'light': 'FFF5F5F5', 'dark': 'FF616161'}, // Light grey / Grey
  ];

  String _getColorForTheme(String colorCode, bool isDark) {
    // Find the color in our list
    final colorData = noteColors.firstWhere(
      (c) => c['light'] == colorCode || c['dark'] == colorCode,
      orElse: () => noteColors[0],
    );
    
    return isDark ? colorData['dark'] : colorData['light'];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Note Color',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Color Grid
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: noteColors.length,
              itemBuilder: (context, index) {
                final colorData = noteColors[index];
                final colorCode = isDark ? colorData['dark'] : colorData['light'];
                final color = Color(int.parse('0x$colorCode'));
                final isSelected = currentColor == colorCode || 
                                   currentColor == colorData['light'] || 
                                   currentColor == colorData['dark'];
                
                return GestureDetector(
                  onTap: () {
                    onColorSelected(colorCode);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary 
                            : Colors.grey.shade300,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: _getContrastColor(color, isDark),
                            size: 24,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Helper to determine if we should use dark or light icon on the color
  Color _getContrastColor(Color backgroundColor, bool isDark) {
    // Calculate relative luminance
    final luminance = backgroundColor.computeLuminance();
    
    // If background is dark, use white. If light, use black
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
