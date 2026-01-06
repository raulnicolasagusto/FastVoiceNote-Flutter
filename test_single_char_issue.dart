import 'lib/src/features/transcription/utils/voice_to_checklist_processor.dart';

/// Test específico para investigar el problema de la "t" en el primer item
void main() {
  print('=== INVESTIGANDO PROBLEMA DE LA "T" ===\n');
  
  // Simular diferentes transcripciones problemáticas que Whisper podría generar
  
  // Caso 1: Whisper transcribe "new list" correctamente pero con "t" adicional
  testCase('new list t eggs, milk, chocolate', 'en');
  
  // Caso 2: "new list " con espacio extra y luego items
  testCase('new list  eggs, milk, chocolate', 'en');
  
  // Caso 3: Transcripción con caracteres extraños al inicio
  testCase('new list to eggs, milk, chocolate', 'en');
  
  // Caso 4: Caso normal que debería funcionar bien
  testCase('new list eggs, milk, chocolate', 'en');
  
  // Caso 5: Con coma después de "new list"
  testCase('new list, eggs, milk, chocolate', 'en');
}

void testCase(String input, String language) {
  print('Input: "$input"');
  
  // Simular el procesamiento paso a paso
  final normalizedText = input.toLowerCase().trim();
  final keyword = 'new list';
  
  if (normalizedText.startsWith(keyword)) {
    final keywordEndIndex = keyword.length;
    print('  Keyword found: "$keyword" (ends at index $keywordEndIndex)');
    
    var remainingText = input.substring(keywordEndIndex).trim();
    print('  After keyword: "$remainingText"');
    
    // Eliminar coma inicial
    if (remainingText.startsWith(',')) {
      remainingText = remainingText.substring(1).trim();
      print('  After removing comma: "$remainingText"');
    }
    
    // Eliminar caracteres sueltos al inicio
    final singleCharPattern = RegExp(r'^[a-z]{1,2}\s+', caseSensitive: false);
    final match = singleCharPattern.firstMatch(remainingText);
    if (match != null) {
      print('  Matched single char pattern: "${match.group(0)}"');
      remainingText = remainingText.substring(match.end).trim();
      print('  After removing single char: "$remainingText"');
    }
  }
  
  // Ahora procesar con la función real
  print('\n  Real processing:');
  final processed = VoiceToChecklistProcessor.processTranscription(input, language);
  
  if (processed.isChecklist) {
    print('  Items found: ${processed.checklistItems.length}');
    for (int i = 0; i < processed.checklistItems.length; i++) {
      final item = processed.checklistItems[i];
      print('    ${i + 1}. "${item.text}"');
    }
  }
  
  print('\n---\n');
}
