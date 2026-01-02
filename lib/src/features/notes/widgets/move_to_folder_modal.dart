import 'package:flutter/material.dart';

// Definición de carpetas
class AppFolders {
  static const String folder1 = 'folder1';
  static const String folder2 = 'folder2';
  static const String none = 'none'; // Sin carpeta asignada

  // Default folders
  static const Map<String, String> defaultFolders = {
    folder1: 'Folder 1',
    folder2: 'Folder 2',
    none: 'All Notes',
  };

  // Carpetas dinámicas (creadas por el usuario)
  static Map<String, String> customFolders = {};

  // Obtener todas las carpetas (default + custom)
  static Map<String, String> getAllFolders() {
    final all = Map<String, String>.from(defaultFolders);
    all.addAll(customFolders);
    return all;
  }

  // Agregar una carpeta personalizada
  static void addCustomFolder(String folderId, String folderName) {
    customFolders[folderId] = folderName;
  }

  // Obtener nombre de carpeta
  static String getFolderName(String? folderId) {
    if (folderId == null || folderId == none) return 'All Notes';
    return getAllFolders()[folderId] ?? 'Unknown';
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
    final allFolders = AppFolders.getAllFolders();
    
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
          ListView.builder(
            shrinkWrap: true,
            itemCount: allFolders.length + 1, // +1 for "All Notes"
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: const Text('All Notes'),
                  onTap: () {
                    onFolderSelected(null);
                    Navigator.of(context).pop();
                  },
                );
              }
              
              final entries = allFolders.entries.toList();
              final key = entries[index - 1].key;
              final value = entries[index - 1].value;
              
              return ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(value),
                onTap: () {
                  onFolderSelected(key);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
