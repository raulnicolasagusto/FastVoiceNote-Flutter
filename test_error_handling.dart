import 'lib/src/features/transcription/utils/voice_to_checklist_processor.dart';

/// Test para verificar que todavía maneja errores de transcripción
void main() {
  print('=== VERIFICANDO QUE ERRORES SON MANEJADOS ===\n');
  
  // Caso 1: Error de transcripción con letra suelta seguida de coma
  testCase('new list t, eggs, milk, chocolate', 'en');
  testCase('new list x, eggs, milk', 'en');
  
  // Caso 2: Casos normales que deben funcionar perfectamente
  testCase('new list a book, milk, eggs', 'en');
  testCase('new list to buy, eggs, milk', 'en');
  testCase('nueva lista el pan, la leche, huevos', 'es');
  
  // Caso 3: Sin error, texto normal
  testCase('new list eggs, milk, chocolate', 'en');
  testCase('new list, eggs, milk, chocolate', 'en');
  
  print('\n=== VERIFICANDO CASOS ORIGINALES DEL TEST ===\n');
  
  // Casos originales del test
  testCase('new list milk, eggs, cookies', 'en');
  testCase('new list, eggs, milk, chocolate', 'en');
  testCase('nueva lista manzanas, leche, pan, y huevos', 'es');
}

void testCase(String input, String language) {
  print('Input: "$input" (lang: $language)');
  
  final processed = VoiceToChecklistProcessor.processTranscription(input, language);
  
  if (processed.isChecklist) {
    print('  ✓ Checklist detected');
    print('  Items (${processed.checklistItems.length}):');
    for (int i = 0; i < processed.checklistItems.length; i++) {
      final item = processed.checklistItems[i];
      print('    ${i + 1}. "${item.text}"');
    }
  } else {
    print('  ✗ NOT detected as checklist');
  }
  
  print('');
}
