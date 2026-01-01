import 'package:flutter/material.dart';

// Definición de carpetas fijas
class AppFolders {
  static const String folder1 = 'folder1';
  static const String folder2 = 'folder2';
  static const String none = 'none'; // Sin carpeta asignada

  static const Map<String, String> folders = {
    folder1: 'Folder 1',
    folder2: 'Folder 2',
    none: 'All Notes', // Opción para volver a "todas las notas"
  };

  static String getFolderName(String? folderId) {
    if (folderId == null || folderId == none) return 'All Notes';
    return folders[folderId] ?? 'Unknown';
  }
}

class MoveToFolderModal extends StatelessWidget {
  final Function(String? folderId) onFolderSelected;

  const MoveToFolderModal({
    super.key,
    required this.onFolderSelected,
  });

  @override
  Widget build(BuildContext context) {
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
                  'Move to Folder',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Folders list
          ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: const Text('All Notes'),
                onTap: () {
                  onFolderSelected(null);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: const Text('Folder 1'),
                onTap: () {
                  onFolderSelected(AppFolders.folder1);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: const Text('Folder 2'),
                onTap: () {
                  onFolderSelected(AppFolders.folder2);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
