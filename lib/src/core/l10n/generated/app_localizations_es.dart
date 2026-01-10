// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'FastVoiceNote';

  @override
  String get notesTitle => 'Notas';

  @override
  String get searchPlaceholder => 'Buscar notas';

  @override
  String get allTab => 'Todas';

  @override
  String get folderTab => 'Carpeta';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get showTips => 'Mostrar Consejos';

  @override
  String get language => 'Idioma';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get portuguese => 'Portugués';

  @override
  String get newNote => 'Nueva Nota';

  @override
  String get quickVoiceNote => 'Nota de Voz Rápida';

  @override
  String get recording => 'Grabando...';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get moreOptions => 'Más Opciones';

  @override
  String get checklist => 'Lista de Tareas';

  @override
  String get reminder => 'Recordatorio';

  @override
  String get disableReminder => 'Desactivar Recordatorio';

  @override
  String get reminderDisabled => 'Recordatorio desactivado';

  @override
  String get lock => 'Bloquear';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get share => 'Compartir';

  @override
  String get addToHomeScreen => 'Agregar a Pantalla de Inicio';

  @override
  String get addItem => 'Agregar elemento';

  @override
  String get deleteConfirm => 'Eliminar';

  @override
  String get deleteCancel => 'Cancelar';

  @override
  String get deleteSingleTitle => 'Eliminar nota';

  @override
  String get deleteSingleMessage => '¿Seguro que deseas eliminar esta nota?';

  @override
  String get deleteMultipleTitle => 'Eliminar notas';

  @override
  String deleteMultipleMessage(Object count) {
    return '¿Eliminar $count notas seleccionadas?';
  }

  @override
  String get addMedia => 'Agregar Multimedia';

  @override
  String get takePicture => 'Tomar una foto';

  @override
  String get uploadFile => 'Subir una foto o archivo';

  @override
  String get photoAddedSuccess => 'Foto agregada exitosamente';

  @override
  String get noteLockedTitle => 'Nota Bloqueada';

  @override
  String get noteLockedMessage =>
      'La nota está bloqueada. Desbloquéala para hacer cambios.';

  @override
  String get noteLockedDeleteMultiple =>
      'No se pueden eliminar las notas. Una o más notas están bloqueadas.';

  @override
  String get noteLocked => 'Nota bloqueada';

  @override
  String get noteUnlocked => 'Nota desbloqueada';

  @override
  String get ok => 'Aceptar';

  @override
  String get shareOptions => 'Opciones para Compartir';

  @override
  String get shareAsImage => 'Compartir como imagen';

  @override
  String get shareAsText => 'Compartir como texto';

  @override
  String get createdWithNotes => 'Creado con Fast Voice Note';

  @override
  String get tipChecklistVoice =>
      'Toca el botón de nota de voz rápida y di \"nueva lista\" seguido de los elementos. Crearemos automáticamente una lista que puedes marcar mientras avanzas.';

  @override
  String get tipReminder =>
      'Después de grabar una nota o crear una lista, di algo como \"recuérdame mañana a las 4 PM\". Se programará un recordatorio para esa nota.';

  @override
  String get shortcutQuickVoice => 'Nota de Voz Rápida';

  @override
  String get shortcutQuickVoiceDesc =>
      'Comenzar a grabar una nota de voz al instante';

  @override
  String get processing => 'Procesando...';

  @override
  String get tapToCreateFirstNote => 'Toca para crear tu primera nota';

  @override
  String get reminderNotificationTitle => 'Recordatorio de Nota';

  @override
  String reminderNotificationBody(Object title) {
    return 'Recordatorio para la nota: $title';
  }

  @override
  String get reminderSetForToday => 'Recordatorio activado para hoy a las';

  @override
  String get reminderSetForDate => 'Recordatorio activado para el';

  @override
  String get tapToAddContent => 'Toca para agregar contenido';
}
