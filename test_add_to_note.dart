import 'lib/src/features/transcription/utils/voice_add_to_note_processor.dart';

/// Test para la funcionalidad de agregar contenido a notas con voz
void main() {
  print('=== TESTS PARA AGREGAR A CHECKLIST ===\n');
  
  // Tests en inglés
  print('=== INGLÉS - ADD TO LIST ===');
  testAddToNote('add milk, eggs, bread', 'en', isChecklist: true);
  testAddToNote('add to this list eggs, milk, chocolate', 'en', isChecklist: true);
  testAddToNote('add items apple, banana', 'en', isChecklist: true);
  testAddToNote('add: tomatoes, onions', 'en', isChecklist: true);
  
  print('\n=== ESPAÑOL - AGREGAR A LISTA ===');
  testAddToNote('agregar leche, huevos, pan', 'es', isChecklist: true);
  testAddToNote('agregar a la lista tomates, cebollas', 'es', isChecklist: true);
  testAddToNote('añadir manzanas, plátanos', 'es', isChecklist: true);
  testAddToNote('agrega: arroz, pollo', 'es', isChecklist: true);
  
  print('\n=== PORTUGUÊS - ADICIONAR A LISTA ===');
  testAddToNote('adicionar leite, ovos, pão', 'pt', isChecklist: true);
  testAddToNote('adicionar à lista tomates, cebolas', 'pt', isChecklist: true);
  testAddToNote('adicione maçãs, bananas', 'pt', isChecklist: true);
  
  print('\n=== TEXTO REGULAR (NO ADD TRIGGER) ===');
  testAddToNote('I need to buy groceries tomorrow', 'en', isChecklist: true);
  testAddToNote('Tengo que comprar esto mañana', 'es', isChecklist: true);
  testAddToNote('Preciso comprar amanhã', 'pt', isChecklist: true);
  
  print('\n=== TEXTO EN NOTA REGULAR (NO CHECKLIST) ===');
  testAddToNote('add milk and eggs', 'en', isChecklist: false);
  testAddToNote('This is just regular text', 'en', isChecklist: false);
  testAddToNote('agregar notas sobre la reunión', 'es', isChecklist: false);
}

void testAddToNote(String input, String language, {required bool isChecklist}) {
  print('Input: "$input" (lang: $language, isChecklist: $isChecklist)');
  
  final result = VoiceAddToNoteProcessor.processAddToNote(
    transcribedText: input,
    language: language,
    isChecklist: isChecklist,
  );
  
  if (result.shouldAddItems) {
    print('  ✓ Should add items to checklist');
    print('  Items (${result.itemsToAdd.length}):');
    for (int i = 0; i < result.itemsToAdd.length; i++) {
      final item = result.itemsToAdd[i];
      print('    ${i + 1}. "${item.text}"');
    }
  } else {
    print('  → Should add as text');
    print('  Text: "${result.textToAdd}"');
  }
  print('');
}
