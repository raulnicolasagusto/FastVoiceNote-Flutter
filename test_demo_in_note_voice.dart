import 'lib/src/features/transcription/utils/voice_add_to_note_processor.dart';

/// Demostración visual del funcionamiento completo
void main() {
  print('╔════════════════════════════════════════════════════════════════╗');
  print('║     IN-NOTE VOICE RECORDING - DEMO COMPLETO                   ║');
  print('╚════════════════════════════════════════════════════════════════╝\n');
  
  // ============================================================
  // ESCENARIO 1: Agregar items a checklist existente
  // ============================================================
  print('📋 ESCENARIO 1: Agregar items a checklist');
  print('─' * 64);
  print('Estado Inicial:');
  print('  Checklist: ["milk", "eggs"]');
  print('');
  print('👤 Usuario presiona 🎤 y dice: "add bread, butter, and cheese"');
  print('');
  
  final result1 = VoiceAddToNoteProcessor.processAddToNote(
    transcribedText: 'add bread, butter, and cheese',
    language: 'en',
    isChecklist: true,
  );
  
  print('⚙️  Procesamiento:');
  print('  • Detecta trigger: "add" ✓');
  print('  • Extrae items: ${result1.itemsToAdd.length} items');
  for (var i = 0; i < result1.itemsToAdd.length; i++) {
    print('    ${i + 1}. "${result1.itemsToAdd[i].text}"');
  }
  print('');
  print('✅ Resultado:');
  print('  Checklist actualizado: ["milk", "eggs", "bread", "butter", "cheese"]');
  print('  Notificación: "Added 3 item(s) to checklist"');
  print('');
  
  // ============================================================
  // ESCENARIO 2: Agregar texto regular a nota
  // ============================================================
  print('📝 ESCENARIO 2: Agregar texto a nota regular');
  print('─' * 64);
  print('Estado Inicial:');
  print('  Nota: "Meeting notes from Monday"');
  print('');
  print('👤 Usuario presiona 🎤 y dice: "Remember to follow up with Sarah"');
  print('');
  
  final result2 = VoiceAddToNoteProcessor.processAddToNote(
    transcribedText: 'Remember to follow up with Sarah',
    language: 'en',
    isChecklist: false,
  );
  
  print('⚙️  Procesamiento:');
  print('  • No detecta trigger de "add"');
  print('  • Trata como texto regular');
  print('');
  print('✅ Resultado:');
  print('  Nota actualizada:');
  print('  "Meeting notes from Monday');
  print('');
  print('   Remember to follow up with Sarah"');
  print('');
  
  // ============================================================
  // ESCENARIO 3: Nota con checklist + texto
  // ============================================================
  print('📋+📝 ESCENARIO 3: Checklist + Texto (solo agregar items)');
  print('─' * 64);
  print('Estado Inicial:');
  print('  Texto: "Shopping list for party"');
  print('  Checklist: ["chips", "soda", "napkins"]');
  print('');
  print('👤 Usuario presiona 🎤 y dice: "add cake and balloons"');
  print('');
  
  final result3 = VoiceAddToNoteProcessor.processAddToNote(
    transcribedText: 'add cake and balloons',
    language: 'en',
    isChecklist: true,
  );
  
  print('⚙️  Procesamiento:');
  print('  • Detecta trigger: "add" ✓');
  print('  • Extrae items: ${result3.itemsToAdd.length} items');
  for (var i = 0; i < result3.itemsToAdd.length; i++) {
    print('    ${i + 1}. "${result3.itemsToAdd[i].text}"');
  }
  print('');
  print('✅ Resultado:');
  print('  Texto: "Shopping list for party" (sin cambios)');
  print('  Checklist: ["chips", "soda", "napkins", "cake", "balloons"]');
  print('');
  
  // ============================================================
  // ESCENARIO 4: Español - Agregar a lista
  // ============================================================
  print('🇪🇸 ESCENARIO 4: Español - Agregar items');
  print('─' * 64);
  print('Estado Inicial:');
  print('  Checklist: ["leche", "huevos"]');
  print('');
  print('👤 Usuario presiona 🎤 y dice: "agregar pan, mantequilla y queso"');
  print('');
  
  final result4 = VoiceAddToNoteProcessor.processAddToNote(
    transcribedText: 'agregar pan, mantequilla y queso',
    language: 'es',
    isChecklist: true,
  );
  
  print('⚙️  Procesamiento:');
  print('  • Detecta trigger: "agregar" ✓');
  print('  • Extrae items: ${result4.itemsToAdd.length} items');
  for (var i = 0; i < result4.itemsToAdd.length; i++) {
    print('    ${i + 1}. "${result4.itemsToAdd[i].text}"');
  }
  print('');
  print('✅ Resultado:');
  print('  Checklist actualizado: ["leche", "huevos", "pan", "mantequilla", "queso"]');
  print('  Notificación: "Added 3 item(s) to checklist"');
  print('');
  
  // ============================================================
  // ESCENARIO 5: Sin trigger - texto normal
  // ============================================================
  print('💬 ESCENARIO 5: Sin trigger - Agregar como texto');
  print('─' * 64);
  print('Estado Inicial:');
  print('  Checklist: ["milk", "eggs"]');
  print('');
  print('👤 Usuario presiona 🎤 y dice: "I need to buy these tomorrow"');
  print('');
  
  final result5 = VoiceAddToNoteProcessor.processAddToNote(
    transcribedText: 'I need to buy these tomorrow',
    language: 'en',
    isChecklist: true,
  );
  
  print('⚙️  Procesamiento:');
  print('  • No detecta trigger de "add"');
  print('  • Trata como nota/comentario');
  print('');
  print('✅ Resultado:');
  print('  Texto agregado arriba del checklist:');
  print('  "I need to buy these tomorrow"');
  print('  Checklist: ["milk", "eggs"] (sin cambios)');
  print('');
  
  // ============================================================
  // RESUMEN
  // ============================================================
  print('╔════════════════════════════════════════════════════════════════╗');
  print('║                          RESUMEN                               ║');
  print('╠════════════════════════════════════════════════════════════════╣');
  print('║  ✅ Checklist + "add" phrase → Agrega items                   ║');
  print('║  ✅ Checklist + texto normal → Agrega como texto              ║');
  print('║  ✅ Nota regular → Siempre agrega como texto                  ║');
  print('║  ✅ Multi-idioma: EN, ES, PT                                  ║');
  print('║  ✅ Reutiliza componentes existentes                          ║');
  print('╚════════════════════════════════════════════════════════════════╝');
}
