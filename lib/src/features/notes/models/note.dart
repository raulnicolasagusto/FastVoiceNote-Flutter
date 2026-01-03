class Note {
  final String id;
  String title;
  String content;
  final DateTime createdAt;
  DateTime updatedAt;
  final String color;
  final bool hasImage;
  final bool hasVoice;
  String? folderId;
  final bool isPinned;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.color,
    this.hasImage = false,
    this.hasVoice = false,
    this.folderId,
    this.isPinned = false,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? color,
    bool? hasImage,
    bool? hasVoice,
    String? folderId,
    bool? isPinned,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      color: color ?? this.color,
      hasImage: hasImage ?? this.hasImage,
      hasVoice: hasVoice ?? this.hasVoice,
      folderId: folderId ?? this.folderId,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  factory Note.fromEntity(dynamic entity) {
    return Note(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      color: entity.color,
      hasImage: entity.hasImage,
      hasVoice: entity.hasVoice,
      folderId: entity.folderId,
      isPinned: entity.isPinned,
    );
  }
}
