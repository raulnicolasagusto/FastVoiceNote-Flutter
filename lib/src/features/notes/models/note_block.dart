import 'package:uuid/uuid.dart';
import 'checklist_item.dart';

enum NoteBlockType { text, image, checklist, file }

abstract class NoteBlock {
  final String id;
  final NoteBlockType type;

  const NoteBlock({required this.id, required this.type});

  Map<String, dynamic> toJson();

  factory NoteBlock.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    final type = NoteBlockType.values.firstWhere(
      (e) => e.toString().split('.').last == typeStr,
    );

    switch (type) {
      case NoteBlockType.text:
        return TextBlock.fromJson(json);
      case NoteBlockType.image:
        return ImageBlock.fromJson(json);
      case NoteBlockType.checklist:
        return ChecklistBlock.fromJson(json);
      case NoteBlockType.file:
        return FileBlock.fromJson(json);
    }
  }
}

class TextBlock extends NoteBlock {
  final String content; // JSON Delta or Plain Text

  const TextBlock({required String id, this.content = ''})
    : super(id: id, type: NoteBlockType.text);

  factory TextBlock.create({String content = ''}) {
    return TextBlock(id: const Uuid().v4(), content: content);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'id': id, 'type': 'text', 'content': content};
  }

  factory TextBlock.fromJson(Map<String, dynamic> json) {
    return TextBlock(
      id: json['id'] as String,
      content: json['content'] as String? ?? '',
    );
  }

  TextBlock copyWith({String? content}) {
    return TextBlock(id: id, content: content ?? this.content);
  }
}

class ImageBlock extends NoteBlock {
  final String imagePath;
  final String? caption;

  const ImageBlock({required String id, required this.imagePath, this.caption})
    : super(id: id, type: NoteBlockType.image);

  factory ImageBlock.create({required String imagePath, String? caption}) {
    return ImageBlock(
      id: const Uuid().v4(),
      imagePath: imagePath,
      caption: caption,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': 'image',
      'imagePath': imagePath,
      'caption': caption,
    };
  }

  factory ImageBlock.fromJson(Map<String, dynamic> json) {
    return ImageBlock(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      caption: json['caption'] as String?,
    );
  }
}

class ChecklistBlock extends NoteBlock {
  final List<ChecklistItem> items;

  const ChecklistBlock({required String id, this.items = const []})
    : super(id: id, type: NoteBlockType.checklist);

  factory ChecklistBlock.create({List<ChecklistItem>? items}) {
    return ChecklistBlock(id: const Uuid().v4(), items: items ?? []);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': 'checklist',
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  factory ChecklistBlock.fromJson(Map<String, dynamic> json) {
    return ChecklistBlock(
      id: json['id'] as String,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => ChecklistItem.fromJson(e))
              .toList() ??
          [],
    );
  }

  ChecklistBlock copyWith({List<ChecklistItem>? items}) {
    return ChecklistBlock(id: id, items: items ?? this.items);
  }
}

class FileBlock extends NoteBlock {
  final String filePath;
  final String fileName;

  const FileBlock({
    required String id,
    required this.filePath,
    required this.fileName,
  }) : super(id: id, type: NoteBlockType.file);

  factory FileBlock.create({
    required String filePath,
    required String fileName,
  }) {
    return FileBlock(
      id: const Uuid().v4(),
      filePath: filePath,
      fileName: fileName,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': 'file',
      'filePath': filePath,
      'fileName': fileName,
    };
  }

  factory FileBlock.fromJson(Map<String, dynamic> json) {
    return FileBlock(
      id: json['id'] as String,
      filePath: json['filePath'] as String,
      fileName: json['fileName'] as String,
    );
  }
}
