import 'lib/src/features/transcription/utils/voice_to_checklist_processor.dart';

/// Test para encontrar el caso donde "t" aparece en el primer item
void main() {
  print('=== BUSCANDO CASO DONDE "T" APARECE EN EL PRIMER ITEM ===\n');
  
  // Si el usuario dice "new list tomatoes, eggs, milk"
  // La "t" de "tomatoes" podría ser eliminada incorrectamente
  
  testCase('new list tomatoes, eggs, milk', 'en');
  testCase('new list turkey, eggs, milk', 'en');  
  testCase('new list tea, coffee, milk', 'en');
  
  // Español
  testCase('nueva lista tomates, huevos, leche', 'es');
  testCase('lista nueva te, café, leche', 'es'); // "te" = tea in Spanish
  
  print('\n=== CASO CRÍTICO: Item que empieza con 1-2 letras ===\n');
  
  // Items que empiezan con 1-2 letras seguidas de espacio
  testCase('new list a book, milk, eggs', 'en');
  testCase('new list to do something', 'en');
  testCase('nueva lista el pan, la leche', 'es');
}

void testCase(String input, String language) {
  print('Input: "$input" (lang: $language)');
  
  final processed = VoiceToChecklistProcessor.processTranscription(input, language);
  
  if (processed.isChecklist) {
    print('  Items found: ${processed.checklistItems.length}');
    for (int i = 0; i < processed.checklistItems.length; i++) {
      final item = processed.checklistItems[i];
      print('    ${i + 1}. "${item.text}"');
    }
  } else {
    print('  NOT detected as checklist');
  }
  
  print('');
}
