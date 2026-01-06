import '../../../features/notes/models/checklist_item.dart';
import '../../../features/notes/models/checklist_utils.dart';

/// Procesa texto transcrito para agregar contenido a una nota existente
/// Detecta frases de "agregar a lista" y extrae elementos o devuelve texto plano
class VoiceAddToNoteProcessor {
  
  /// Palabras/frases clave que indican que el usuario quiere agregar items a una lista
  static const Map<String, List<String>> _addToListTriggers = {
    'en': [
      'add to this list',
      'add to the list',
      'add to list',
      'add items',
      'add item',
      'add these',
      'add this',
      'add',
      'also add',
      'please add',
    ],
    'es': [
      'agregar a esta lista',
      'agregar a la lista',
      'agregar a lista',
      'agregar',
      'agrega',
      'añadir a la lista',
      'añadir',
      'añade',
      'agrega esto',
      'también agregar',
      'por favor agregar',
    ],
    'pt': [
      'adicionar a esta lista',
      'adicionar à lista',
      'adicionar',
      'adicione',
      'adiciona',
      'acrescentar',
      'também adicionar',
      'por favor adicionar',
    ],
  };

  /// Procesa la transcripción para determinar si el usuario quiere agregar items
  /// o simplemente agregar texto a la nota
  static AddToNoteResult processAddToNote({
    required String transcribedText,
    required String language,
    required bool isChecklist,
  }) {
    if (transcribedText.trim().isEmpty) {
      return AddToNoteResult(
        shouldAddItems: false,
        textToAdd: transcribedText,
      );
    }

    // Si no es un checklist, simplemente devolver el texto
    if (!isChecklist) {
      return AddToNoteResult(
        shouldAddItems: false,
        textToAdd: transcribedText,
      );
    }

    final normalizedText = transcribedText.toLowerCase().trim();
    final triggers = _addToListTriggers[language] ?? _addToListTriggers['en']!;
    
    // Buscar triggers al inicio del texto
    String? matchedTrigger;
    int triggerEndIndex = 0;
    
    for (final trigger in triggers) {
      if (normalizedText.startsWith(trigger)) {
        matchedTrigger = trigger;
        triggerEndIndex = trigger.length;
        break;
      }
    }

    // Si no se encontró trigger, devolver como texto plano
    if (matchedTrigger == null) {
      return AddToNoteResult(
        shouldAddItems: false,
        textToAdd: transcribedText,
      );
    }

    // Extraer el texto después del trigger
    var remainingText = transcribedText.substring(triggerEndIndex).trim();
    
    // Eliminar comas o dos puntos iniciales
    if (remainingText.startsWith(',') || remainingText.startsWith(':')) {
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
    
    // Si no hay texto después del trigger, devolver vacío
    if (remainingText.isEmpty) {
      return AddToNoteResult(
        shouldAddItems: true,
        itemsToAdd: [],
      );
    }

    // Extraer items de la lista
    final items = _extractItems(remainingText, language);
    
    return AddToNoteResult(
      shouldAddItems: true,
      itemsToAdd: items,
    );
  }

  /// Extrae items individuales del texto
  static List<ChecklistItem> _extractItems(String text, String language) {
    final items = <ChecklistItem>[];
    
    // Separadores por idioma
    final separators = _getSeparators(language);
    
    // Dividir por separadores
    List<String> parts = [text];
    
    for (final separator in separators) {
      List<String> newParts = [];
      for (final part in parts) {
        if (separator == ',') {
          newParts.addAll(part.split(','));
        } else {
          final regex = RegExp('\\s+$separator\\s+', caseSensitive: false);
          newParts.addAll(part.split(regex));
        }
      }
      parts = newParts;
    }
    
    // Limpiar y crear items
    final cleanedParts = parts
        .map((part) => _cleanItemText(part))
        .where((part) => part.isNotEmpty && !_isSeparatorWord(part, separators))
        .toList();
    
    if (cleanedParts.isEmpty) {
      // Si no hay items válidos, crear uno con el texto original
      final cleaned = _cleanItemText(text);
      if (cleaned.isNotEmpty) {
        items.add(ChecklistItem(
          id: ChecklistUtils.generateItemId(),
          text: cleaned,
        ));
      }
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
  static List<String> _getSeparators(String language) {
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

  /// Limpia el texto de un item individual
  static String _cleanItemText(String text) {
    // Trim espacios
    var cleaned = text.trim();
    
    // Eliminar puntos finales opcionales
    if (cleaned.endsWith('.')) {
      cleaned = cleaned.substring(0, cleaned.length - 1).trim();
    }
    
    // Eliminar comillas
    cleaned = cleaned.replaceAll('"', '').replaceAll("'", '');
    
    return cleaned;
  }

  /// Verifica si un texto es solo una palabra separadora
  static bool _isSeparatorWord(String text, List<String> separators) {
    final normalized = text.toLowerCase().trim();
    return separators.any((sep) => sep != ',' && normalized == sep);
  }
}

/// Resultado del procesamiento de transcripción para agregar a nota
class AddToNoteResult {
  final bool shouldAddItems;
  final List<ChecklistItem> itemsToAdd;
  final String textToAdd;

  AddToNoteResult({
    required this.shouldAddItems,
    this.itemsToAdd = const [],
    this.textToAdd = '',
  });
}
