import 'lib/src/features/transcription/utils/voice_to_checklist_processor.dart';

/// Test específico para el caso "new listt"
void main() {
  print('=== PROBANDO CASO "new listt" ===\n');
  
  testCase('new listt eggs, milk, chocolate', 'en');
  testCase('new list t eggs, milk, chocolate', 'en');
  testCase('new list t, eggs, milk', 'en');
  
  print('\n=== VERIFICANDO QUE "a" SE PRESERVA ===\n');
  testCase('new list a book, eggs, milk', 'en');
  testCase('new list a, eggs, milk', 'en');
  
  print('\n=== VERIFICANDO OTRAS LETRAS VÁLIDAS ===\n');
  testCase('new list I need milk, eggs', 'en');
  testCase('new list y luego comprar pan', 'es');
  testCase('new list o sea comprar todo', 'es');
}

void testCase(String input, String language) {
  print('Input: "$input"');
  
  final processed = VoiceToChecklistProcessor.processTranscription(input, language);
  
  if (processed.isChecklist) {
    print('  Items:');
    for (int i = 0; i < processed.checklistItems.length; i++) {
      final item = processed.checklistItems[i];
      print('    ${i + 1}. "${item.text}"');
    }
  }
  print('');
}
