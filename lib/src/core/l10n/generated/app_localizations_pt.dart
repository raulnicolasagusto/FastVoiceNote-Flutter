// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get onboardingSkip => 'Pular';

  @override
  String get onboardingStart => 'Começar';

  @override
  String get onboardingNext => 'Próximo';

  @override
  String get onboardingStep1Title => 'Atalho de Gravação Rápida';

  @override
  String get onboardingStep1Desc =>
      'Pressione e segure o ícone do app para gravar imediatamente. Transcreva suas notas de voz sem abrir o aplicativo primeiro.';

  @override
  String get onboardingStep2Title => 'Listas Inteligentes';

  @override
  String get onboardingStep2Desc =>
      'Crie listas com sua voz! Basta dizer: \"Nova lista de compras, açúcar, ovos, café...\" e nós organizamos para você.';

  @override
  String get onboardingStep3Title => 'Gravador de Reuniões';

  @override
  String get onboardingStep3Desc =>
      'Grave reuniões longas de até 1 hora. Transcrevemos tudo e organizamos para você. Perfeito para aulas e reuniões de negócios.';

  @override
  String get onboardingStep4Title => 'Notas Multimídia';

  @override
  String get onboardingStep4Desc =>
      'Adicione fotos, desenhos, notificações e arquivos às suas notas. O FastVoiceNote é totalmente gratuito. Aproveite para capturar suas ideias!';

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
  String get reminder => 'Lembrete';

  @override
  String get disableReminder => 'Desativar Lembrete';

  @override
  String get reminderDisabled => 'Lembrete desativado';

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

  @override
  String get shareOptions => 'Opções de Compartilhamento';

  @override
  String get shareAsImage => 'Compartilhar como imagem';

  @override
  String get shareAsText => 'Compartilhar como texto';

  @override
  String get createdWithNotes => 'Criado com Fast Voice Note';

  @override
  String get tipChecklistVoice =>
      'Toque no botão de nota de voz rápida e diga \"nova lista\" seguido dos itens. Criaremos automaticamente uma lista que você pode marcar enquanto avança.';

  @override
  String get tipReminder =>
      'Depois de gravar uma nota ou criar uma lista, diga algo como \"lembre-me amanhã às 4 PM\". Um lembrete será agendado para essa nota.';

  @override
  String get shortcutQuickVoice => 'Nota de Voz Rápida';

  @override
  String get shortcutQuickVoiceDesc =>
      'Começar a gravar uma nota de voz instantaneamente';

  @override
  String get processing => 'Processando...';

  @override
  String get tapToCreateFirstNote => 'Toque para criar sua primeira nota';

  @override
  String get reminderNotificationTitle => 'Lembrete de Nota';

  @override
  String reminderNotificationBody(Object title) {
    return 'Lembrete para a nota: $title';
  }

  @override
  String get reminderSetForToday => 'Lembrete ativado para hoje às';

  @override
  String get reminderSetForDate => 'Lembrete ativado para';

  @override
  String get tapToAddContent => 'Toque para adicionar conteúdo';

  @override
  String processingChunk(int currentChunk, int totalChunks) {
    return 'Processando fragmento $currentChunk de $totalChunks';
  }

  @override
  String get meeting => 'Reunião';

  @override
  String get recordMeeting => 'Gravar Reunião';

  @override
  String get inaudible => '[Inaudível]';

  @override
  String get meetingMetadataTitle => 'Metadados da Reunião';

  @override
  String get meetingDuration => 'Duração';

  @override
  String get meetingChunks => 'Fragmentos';

  @override
  String get meetingQuality => 'Qualidade';

  @override
  String get transcribe => 'TRANSCREVER';

  @override
  String get noTextDetected => 'Nenhum texto detectado na imagem';

  @override
  String get transcribing => 'Transcrevendo...';

  @override
  String get drawing => 'Desenho';

  @override
  String get drawingStudio => 'Estúdio de Desenho';

  @override
  String get brush => 'Pincel';

  @override
  String get eraser => 'Borracha';

  @override
  String get undo => 'Desfazer';

  @override
  String get redo => 'Refazer';

  @override
  String get colors => 'Cores';

  @override
  String get strokeSize => 'Tamanho do traço';

  @override
  String get openFileTitle => 'Abrir arquivo?';

  @override
  String get openFileMessage =>
      'Deseja abrir este arquivo com um aplicativo externo?';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';
}
