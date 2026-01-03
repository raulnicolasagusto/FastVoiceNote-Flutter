import '../../../features/notes/models/checklist_item.dart';
import '../../../features/notes/models/checklist_utils.dart';

/// Procesa texto transcrito para detectar y convertir listas a checklists automáticamente
class VoiceToChecklistProcessor {
  
  /// Palabras clave que activan la creación de checklist (en múltiples idiomas)
  static const Map<String, List<String>> _triggerKeywords = {
    'en': [
      'new list',
      'new grocery list', 
      'new checklist',
      'shop list',
      'new shop list',
      'shopping list',
      'new shopping list',
      'grocery checklist',
      'todo list',
      'new todo list',
      'task list',
      'new task list',
    ],
    'es': [
      'nueva lista',
      'lista nueva',
      'lista de compras',
      'nueva lista de compras',
      'lista del super',
      'lista mercado',
      'lista de tareas',
      'nueva lista de tareas',
      'checklist',
      'nuevo checklist',
      'lista para comprar',
    ],
    'pt': [
      'nova lista',
      'lista nova',
      'lista de compras',
      'nova lista de compras',
      'lista do mercado',
      'lista de tarefas',
      'nova lista de tarefas',
      'checklist',
      'novo checklist',
      'lista para comprar',
    ],
  };

  /// Separadores comunes para elementos de lista
  static const _itemSeparators = [',', 'and', 'y', 'e', 'also', 'también', 'também'];

  /// Procesa el texto transcrito y determina si debe convertirse a checklist
  static ProcessedTranscription processTranscription(String transcribedText, String language) {
    if (transcribedText.trim().isEmpty) {
      return ProcessedTranscription(
        originalText: transcribedText,
        isChecklist: false,
      );
    }

    final normalizedText = transcribedText.toLowerCase().trim();
    final keywords = _triggerKeywords[language] ?? _triggerKeywords['en']!;
    
    // Buscar palabras clave al inicio del texto
    String? matchedKeyword;
    int keywordEndIndex = 0;
    
    for (final keyword in keywords) {
      if (normalizedText.startsWith(keyword)) {
        matchedKeyword = keyword;
        keywordEndIndex = keyword.length;
        break;
      }
    }

    // Si no se encontró palabra clave, devolver texto normal
    if (matchedKeyword == null) {
      return ProcessedTranscription(
        originalText: transcribedText,
        isChecklist: false,
      );
    }

    // Extraer el texto después de la palabra clave
    final remainingText = transcribedText.substring(keywordEndIndex).trim();
    
    // Si no hay texto después de la palabra clave, crear lista vacía
    if (remainingText.isEmpty) {
      return ProcessedTranscription(
        originalText: '',
        isChecklist: true,
        checklistItems: [
          ChecklistItem(
            id: ChecklistUtils.generateItemId(),
            text: '',
          ),
        ],
      );
    }

    // Procesar el texto restante para extraer elementos
    final items = _extractListItems(remainingText, language);
    
    return ProcessedTranscription(
      originalText: '',
      isChecklist: true,
      checklistItems: items,
    );
  }

  /// Extrae elementos individuales del texto después de la palabra clave
  static List<ChecklistItem> _extractListItems(String text, String language) {
    final items = <ChecklistItem>[];
    
    // Primero intentar separar por comas y conectores comunes
    final separatorsForLang = _getSeparatorsForLanguage(language);
    
    // Crear patrón regex para separadores
    final separatorPattern = separatorsForLang.map((sep) => '\\b$sep\\b').join('|');
    final regex = RegExp('($separatorPattern)', caseSensitive: false);
    
    // Dividir el texto usando los separadores
    final parts = text.split(regex).where((part) => 
      part.trim().isNotEmpty && !separatorsForLang.contains(part.trim().toLowerCase())
    ).toList();
    
    // Si no se encontraron separadores, tratar todo como un solo elemento
    if (parts.length <= 1) {
      items.add(ChecklistItem(
        id: ChecklistUtils.generateItemId(),
        text: text.trim(),
      ));
    } else {
      // Crear un elemento para cada parte
      for (final part in parts) {
        final cleanedPart = _cleanItemText(part.trim());
        if (cleanedPart.isNotEmpty) {
          items.add(ChecklistItem(
            id: ChecklistUtils.generateItemId(),
            text: cleanedPart,
          ));
        }
      }
    }
    
    // Si no se creó ningún elemento, crear uno vacío
    if (items.isEmpty) {
      items.add(ChecklistItem(
        id: ChecklistUtils.generateItemId(),
        text: '',
      ));
    }
    
    return items;
  }

  /// Obtiene separadores específicos para el idioma
  static List<String> _getSeparatorsForLanguage(String language) {
    switch (language) {
      case 'es':
        return [',', 'y', 'también', 'luego', 'después'];
      case 'pt':
        return [',', 'e', 'também', 'depois', 'então'];
      case 'en':
      default:
        return [',', 'and', 'also', 'then', 'plus'];
    }
  }

  /// Limpia el texto de un elemento individual
  static String _cleanItemText(String text) {
    return text
        .trim()
        .replaceAll(RegExp(r'^[,.\s]+'), '') // Remover puntuación al inicio
        .replaceAll(RegExp(r'[,.\s]+$'), '') // Remover puntuación al final
        .trim();
  }

  /// Genera el contenido final para la nota (texto + checklist en formato JSON)
  static String generateNoteContent(ProcessedTranscription processed) {
    if (!processed.isChecklist || processed.checklistItems.isEmpty) {
      return processed.originalText;
    }
    
    return ChecklistUtils.itemsToJson(processed.checklistItems, processed.originalText);
  }
}

/// Resultado del procesamiento de transcripción
class ProcessedTranscription {
  final String originalText;
  final bool isChecklist;
  final List<ChecklistItem> checklistItems;

  ProcessedTranscription({
    required this.originalText,
    required this.isChecklist,
    this.checklistItems = const [],
  });
}