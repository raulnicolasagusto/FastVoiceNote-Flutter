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
}
