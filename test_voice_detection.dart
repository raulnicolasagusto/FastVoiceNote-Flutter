import 'lib/src/features/transcription/utils/voice_to_checklist_processor.dart';

/// Ejemplo de prueba para verificar la funcionalidad de detección de listas por voz
void main() {
  // Test casos específicos mencionados por el usuario
  print('=== TESTS ESPECÍFICOS DEL PROBLEMA ===');
  testVoiceToChecklist(
    'new list milk, eggs, cookies',
    'en',
  );
  
  testVoiceToChecklist(
    'new list, eggs, milk, chocolate',
    'en',
  );
  
  testVoiceToChecklist(
    'new list , eggs, milk, chocolate',
    'en',
  );
  
  testVoiceToChecklist(
    'new listt eggs, milk, chocolate',
    'en',
  );
  
  testVoiceToChecklist(
    'lista nueva leche, huevos, galletas',
    'es',
  );

  // Test en inglés
  print('\n=== TESTS EN INGLÉS ===');
  testVoiceToChecklist(
    'new list apple, milk, bread, and eggs',
    'en',
  );
  
  testVoiceToChecklist(
    'shopping list bananas, rice, chicken, also chocolate',
    'en',
  );

  // Test en español
  print('\n=== TESTS EN ESPAÑOL ===');
  testVoiceToChecklist(
    'nueva lista manzanas, leche, pan, y huevos',
    'es',
  );
  
  testVoiceToChecklist(
    'lista de compras plátanos, arroz, pollo, también chocolate',
    'es',
  );

  // Test en portugués
  print('\n=== TESTS EN PORTUGUÉS ===');
  testVoiceToChecklist(
    'nova lista maçãs, leite, pão, e ovos',
    'pt',
  );
  
  testVoiceToChecklist(
    'lista de compras bananas, arroz, frango, também chocolate',
    'pt',
  );

  // Test sin detección
  print('\n=== TESTS SIN DETECCIÓN ===');
  testVoiceToChecklist(
    'This is just a regular note about my day',
    'en',
  );
  
  testVoiceToChecklist(
    'Esta es solo una nota regular sobre mi día',
    'es',
  );
}

void testVoiceToChecklist(String input, String language) {
  print('\nInput: "$input" (lang: $language)');
  
  final processed = VoiceToChecklistProcessor.processTranscription(input, language);
  
  print('Is checklist: ${processed.isChecklist}');
  if (processed.isChecklist) {
    print('Items found: ${processed.checklistItems.length}');
    for (int i = 0; i < processed.checklistItems.length; i++) {
      final item = processed.checklistItems[i];
      print('  ${i + 1}. "${item.text}" (checked: ${item.isChecked})');
    }
    
    final noteContent = VoiceToChecklistProcessor.generateNoteContent(processed);
    print('Final note content: $noteContent');
  } else {
    print('Regular text: "${processed.originalText}"');
  }
  
  print('---');
}