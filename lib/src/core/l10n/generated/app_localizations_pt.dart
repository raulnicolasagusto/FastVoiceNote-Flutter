// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'FastVoiceNote';

  @override
  String get notesTitle => 'Notas';

  @override
  String get searchPlaceholder => 'Pesquisar notas';

  @override
  String get allTab => 'Todas';

  @override
  String get folderTab => 'Pasta';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get darkMode => 'Modo Escuro';

  @override
  String get showTips => 'Mostrar Dicas';

  @override
  String get language => 'Idioma';

  @override
  String get english => 'Inglês';

  @override
  String get spanish => 'Espanhol';

  @override
  String get portuguese => 'Português';

  @override
  String get newNote => 'Nova Nota';

  @override
  String get quickVoiceNote => 'Nota de Voz Rápida';

  @override
  String get recording => 'Gravando...';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get moreOptions => 'Mais Opções';

  @override
  String get checklist => 'Lista de Tarefas';

  @override
  String get lock => 'Bloquear';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get share => 'Compartilhar';

  @override
  String get addToHomeScreen => 'Adicionar à Tela Inicial';

  @override
  String get addItem => 'Adicionar item';

  @override
  String get deleteConfirm => 'Excluir';

  @override
  String get deleteCancel => 'Cancelar';

  @override
  String get deleteSingleTitle => 'Excluir nota';

  @override
  String get deleteSingleMessage =>
      'Tem certeza de que deseja excluir esta nota?';

  @override
  String get deleteMultipleTitle => 'Excluir notas';

  @override
  String deleteMultipleMessage(Object count) {
    return 'Excluir $count notas selecionadas?';
  }

  @override
  String get addMedia => 'Adicionar Mídia';

  @override
  String get takePicture => 'Tirar uma foto';

  @override
  String get uploadFile => 'Enviar uma foto ou arquivo';

  @override
  String get photoAddedSuccess => 'Foto adicionada com sucesso';

  @override
  String get noteLockedTitle => 'Nota Bloqueada';

  @override
  String get noteLockedMessage =>
      'A nota está bloqueada. Desbloqueie para fazer alterações.';

  @override
  String get noteLockedDeleteMultiple =>
      'Não é possível excluir notas. Uma ou mais notas estão bloqueadas.';

  @override
  String get noteLocked => 'Nota bloqueada';

  @override
  String get noteUnlocked => 'Nota desbloqueada';

  @override
  String get ok => 'OK';
}
