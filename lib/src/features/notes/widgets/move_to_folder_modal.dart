import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

// Definición de carpetas
class AppFolders {
  static const String folder1 = 'folder1';
  static const String none = 'none'; // Sin carpeta asignada

  // Default folders
  static const Map<String, String> defaultFolders = {
    folder1: 'Folder 1',
  };

  // Carpetas dinámicas (creadas por el usuario)
  static Map<String, String> customFolders = {};

  // Cargar carpetas desde archivo
  static Future<void> loadCustomFolders() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/custom_folders.json');
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final Map<String, dynamic> decoded = json.decode(jsonString);
        customFolders = decoded.cast<String, String>();
      }
    } catch (e) {
      // Si falla, continuar con carpetas vacías
    }
  }

  // Guardar carpetas en archivo
  static Future<void> _saveCustomFolders() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/custom_folders.json');
      final jsonString = json.encode(customFolders);
      await file.writeAsString(jsonString);
    } catch (e) {
      // Si falla, continuar sin guardar
    }
  }

  // Obtener todas las carpetas (default + custom)
  static Map<String, String> getAllFolders() {
    final all = Map<String, String>.from(defaultFolders);
    all.addAll(customFolders);
    return all;
  }

  // Agregar una carpeta personalizada
  static Future<void> addCustomFolder(String folderId, String folderName) async {
    customFolders[folderId] = folderName;
    await _saveCustomFolders();
  }

  // Renombrar una carpeta personalizada
  static Future<void> renameFolder(String folderId, String newName) async {
    if (customFolders.containsKey(folderId)) {
      customFolders[folderId] = newName;
      await _saveCustomFolders();
    }
  }

  // Eliminar una carpeta personalizada
  static Future<void> deleteFolder(String folderId) async {
    customFolders.remove(folderId);
    await _saveCustomFolders();
  }

  // Verificar si es una carpeta por defecto (no se puede eliminar)
  static bool isDefaultFolder(String folderId) {
    return defaultFolders.containsKey(folderId);
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
