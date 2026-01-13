import 'dart:convert';
import '../../../core/database/app_database.dart';
import 'checklist_utils.dart';
import 'note_block.dart';

class NoteContentParser {
  static const int kVersion = 1;

  /// Parses the stored content string into a list of NoteBlocks.
  /// Handles legacy formats (plain text, separate checklist, etc.) by migrating them.
  static List<NoteBlock> parse(
    String content,
    List<AttachmentEntity> attachments,
  ) {
    if (content.isEmpty && attachments.isEmpty) {
      return [TextBlock.create()];
    }

    try {
      // Try to decode as new JSON format
      final Map<String, dynamic> json = jsonDecode(content);
      if (json.containsKey('version') && json['blocks'] != null) {
        final List<dynamic> blocksJson = json['blocks'];
        return blocksJson.map((b) => NoteBlock.fromJson(b)).toList();
      }
    } catch (_) {
      // Not JSON or invalid format, fall back to legacy parsing
    }

    return _migrateLegacyContent(content, attachments);
  }

  /// Migrates legacy content structure to Blocks
  static List<NoteBlock> _migrateLegacyContent(
    String content,
    List<AttachmentEntity> attachments,
  ) {
    // 1. Convert Text/Checklist content
    final List<NoteBlock> blocks = [];

    if (ChecklistUtils.hasChecklist(content)) {
      // If it's a checklist note (which technically might contain text too)
      // The current implementation stored checklist as JSON with 'items' and 'text'.
      // We will split this into:
      // Block 1: TextBlock (if text > 0)
      // Block 2: ChecklistBlock

      final items = ChecklistUtils.jsonToItems(content);
      final text = ChecklistUtils.getText(content);

      if (text.trim().isNotEmpty) {
        blocks.add(TextBlock.create(content: text));
      }

      if (items.isNotEmpty) {
        blocks.add(ChecklistBlock.create(items: items));
      } else if (blocks.isEmpty) {
        // Should not happen if hasChecklist is true, but safe guard
        blocks.add(ChecklistBlock.create());
      }
    } else {
      // Plain text or Rich Text Delta
      // If content string is not empty, add it
      if (content.isNotEmpty) {
        blocks.add(TextBlock.create(content: content));
      }
    }

    // 2. Append Attachments as Blocks
    for (final attachment in attachments) {
      if (attachment.type == 'image') {
        blocks.add(ImageBlock.create(imagePath: attachment.filePath));
      } else {
        blocks.add(
          FileBlock.create(
            filePath: attachment.filePath,
            fileName: attachment.fileName ?? 'Unknown',
          ),
        );
      }
    }

    // Ensure at least one block exists
    if (blocks.isEmpty) {
      blocks.add(TextBlock.create());
    }

    return blocks;
  }

  /// Serializes a list of blocks to a JSON string for storage
  static String serialize(List<NoteBlock> blocks) {
    final Map<String, dynamic> json = {
      'version': kVersion,
      'blocks': blocks.map((b) => b.toJson()).toList(),
    };
    return jsonEncode(json);
  }
}
