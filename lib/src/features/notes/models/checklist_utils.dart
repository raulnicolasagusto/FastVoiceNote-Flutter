import 'dart:convert';
import 'checklist_item.dart';

class ChecklistUtils {
  static const String checklistPrefix = 'CHECKLIST:';

  /// Verifica si el contenido tiene un checklist
  static bool hasChecklist(String content) {
    if (!content.startsWith(checklistPrefix)) {
      return false;
    }
    try {
      final jsonString = content.substring(checklistPrefix.length);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return json.containsKey('checklist');
    } catch (e) {
      return false;
    }
  }

  /// Obtiene el texto original (sin checklist)
  static String getText(String content) {
    if (!content.startsWith(checklistPrefix)) {
      return content;
    }
    
    try {
      final jsonString = content.substring(checklistPrefix.length);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return json['text'] as String? ?? '';
    } catch (e) {
      return content;
    }
  }

  /// Convierte lista de items a JSON string para almacenar
  /// Mantiene el texto original y agrega el checklist
  static String itemsToJson(List<ChecklistItem> items, String originalText) {
    final jsonMap = {
      'text': originalText,
      'checklist': items.map((item) => item.toJson()).toList(),
    };
    final jsonString = jsonEncode(jsonMap);
    return '$checklistPrefix$jsonString';
  }

  /// Convierte JSON string a lista de items
  static List<ChecklistItem> jsonToItems(String content) {
    if (!hasChecklist(content)) {
      return [];
    }

    try {
      final jsonString = content.substring(checklistPrefix.length);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final checklistList = json['checklist'] as List?;
      if (checklistList == null) return [];
      
      return checklistList
          .map((item) => ChecklistItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Agrega un checklist a una nota existente (mantiene el texto original)
  static String addChecklistToContent(String originalText) {
    final items = [ChecklistItem(
      id: generateItemId(),
      text: '',
    )];
    return itemsToJson(items, originalText);
  }

  /// Convierte contenido de vuelta a texto normal (sin checklist)
  static String removeChecklist(String content) {
    return getText(content);
  }

  static int _idCounter = 0;

  /// Genera ID único para un nuevo item
  static String generateItemId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _idCounter++;
    return '${timestamp}_$_idCounter';
  }

  /// Genera una vista previa legible del contenido (texto + checklist)
  static String getPreview(String content) {
    if (!hasChecklist(content)) {
      return content;
    }

    final text = getText(content);
    final items = jsonToItems(content);
    
    final buffer = StringBuffer();
    
    // Agregar texto si existe
    if (text.trim().isNotEmpty) {
      buffer.writeln(text);
      if (items.isNotEmpty) {
        buffer.writeln(); // Línea en blanco entre texto y checklist
      }
    }
    
    // Agregar vista previa del checklist
    for (var item in items) {
      final checkmark = item.isChecked ? '✓' : '☐';
      buffer.writeln('$checkmark ${item.text.isEmpty ? '(vacío)' : item.text}');
    }
    
    return buffer.toString().trim();
  }
}
