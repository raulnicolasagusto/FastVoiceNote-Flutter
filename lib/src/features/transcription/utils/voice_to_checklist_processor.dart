import '../../../features/notes/models/checklist_item.dart';
import '../../../features/notes/models/checklist_utils.dart';

/// Procesa texto transcrito para detectar y convertir listas a checklists automáticamente
class VoiceToChecklistProcessor {
  
  /// Palabras clave que activan la creación de checklist (en múltiples idiomas)
  /// IMPORTANTE: Ordenadas de más largas a más cortas para detectar primero las más específicas
  static const Map<String, List<String>> _triggerKeywords = {
    'en': [
      'new shopping list',
      'new grocery list',
      'grocery checklist',
      'new shop list',
      'new checklist',
      'new todo list',
      'new task list',
      'shopping list',
      'shop list',
      'todo list',
      'task list',
      'new list',
    ],
    'es': [
      'nueva lista de compras',
      'nueva lista de tareas',
      'lista de compras',
      'lista para comprar',
      'lista de tareas',
      'nuevo checklist',
      'lista del super',
      'nueva lista',
      'lista mercado',
      'lista nueva',
      'checklist',
    ],
    'pt': [
      'nova lista de compras',
      'nova lista de tarefas',
      'lista de compras',
      'lista para comprar',
      'lista de tarefas',
      'novo checklist',
      'lista do mercado',
      'nova lista',
      'lista nova',
      'checklist',
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
    // Usar el texto original pero desde la posición correcta
    var remainingText = transcribedText.substring(keywordEndIndex).trim();
    
    // Eliminar coma inicial si existe (caso: "new list, item1, item2")
    if (remainingText.startsWith(',')) {
      remainingText = remainingText.substring(1).trim();
    }
    
    // Eliminar SOLO caracteres sueltos que parecen errores de transcripción
    // Casos cubiertos:
    // 1. Una sola letra seguida de coma: "t, eggs" → "eggs"
    // 2. Una sola letra seguida de espacio y luego contenido: "t eggs" → "eggs"
    //    PERO solo si la siguiente palabra NO forma una frase válida común
    final singleErrorPattern = RegExp(r'^([a-z])\s*,\s*', caseSensitive: false);
    final singleLetterSpace = RegExp(r'^([a-z])\s+([a-z]+)', caseSensitive: false);
    
    final matchError = singleErrorPattern.firstMatch(remainingText);
    if (matchError != null) {
      // Solo una letra seguida de coma, probablemente un error
      remainingText = remainingText.substring(matchError.end).trim();
    } else {
      // Verificar si es una letra seguida de espacio y otra palabra
      final matchLetter = singleLetterSpace.firstMatch(remainingText);
      if (matchLetter != null) {
        final letter = matchLetter.group(1)!.toLowerCase();
        final nextWord = matchLetter.group(2)!.toLowerCase();
        
        // Solo eliminar si NO es un artículo común o preposición que forma frase válida
        // Mantener: "a book", "a dog", etc. (en inglés "a" + sustantivo)
        // Mantener: "I went", "o sea" (conjunciones)
        // Eliminar: "t eggs", "x milk" (errores obvios)
        final validSingleLetterWords = ['a', 'i', 'o', 'u', 'y', 'e'];
        if (!validSingleLetterWords.contains(letter)) {
          // Es probablemente un error, eliminar
          remainingText = remainingText.substring(matchLetter.group(1)!.length).trim();
        }
      }
    }
    
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
    
    // Obtener separadores para el idioma
    final separatorsForLang = _getSeparatorsForLanguage(language);
    
    // Enfoque simple: dividir primero por comas, luego por conectores
    List<String> parts = [text];
    
    // Dividir por cada tipo de separador
    for (final separator in separatorsForLang) {
      List<String> newParts = [];
      for (final part in parts) {
        if (separator == ',') {
          // Para comas, dividir directamente
          newParts.addAll(part.split(','));
        } else {
          // Para palabras conectoras, dividir con espacios
          final regex = RegExp('\\s+$separator\\s+', caseSensitive: false);
          newParts.addAll(part.split(regex));
        }
      }
      parts = newParts;
    }
    
    // Limpiar y filtrar partes
    final cleanedParts = parts
        .map((part) => _cleanItemText(part))
        .where((part) => part.isNotEmpty && !_isSeparatorWord(part, separatorsForLang))
        .toList();
    
    // Crear elementos
    if (cleanedParts.isEmpty) {
      final cleaned = _cleanItemText(text);
      items.add(ChecklistItem(
        id: ChecklistUtils.generateItemId(),
        text: cleaned.isEmpty ? '' : cleaned,
      ));
    } else {
      for (final part in cleanedParts) {
        items.add(ChecklistItem(
          id: ChecklistUtils.generateItemId(),
          text: part,
        ));
      }
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

  /// Verifica si una palabra es un separador
  static bool _isSeparatorWord(String word, List<String> separators) {
    final normalizedWord = word.toLowerCase().trim();
    return separators.any((sep) => sep != ',' && normalizedWord == sep);
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
  final DateTime? reminderAt;

  ProcessedTranscription({
    required this.originalText,
    required this.isChecklist,
    this.checklistItems = const [],
    this.reminderAt,
  });
}