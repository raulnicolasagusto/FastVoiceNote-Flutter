import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../../models/note_block.dart';
import '../../models/rich_text_utils.dart';

class TextBlockWidget extends StatefulWidget {
  final TextBlock block;
  final Function(String) onContentChanged;
  final VoidCallback onDelete;
  final Function(quill.QuillController) onFocus;
  final FocusNode focusNode;
  final bool isEditing;

  const TextBlockWidget({
    super.key,
    required this.block,
    required this.onContentChanged,
    required this.onDelete,
    required this.onFocus,
    required this.focusNode,
    this.isEditing = true,
  });

  @override
  State<TextBlockWidget> createState() => _TextBlockWidgetState();
}

class _TextBlockWidgetState extends State<TextBlockWidget> {
  late quill.QuillController _controller;

  @override
  void initState() {
    super.initState();
    final delta = RichTextUtils.getDelta(widget.block.content);
    _controller = quill.QuillController(
      document: quill.Document.fromDelta(delta),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _controller.addListener(_onChanged);
    widget.focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (widget.focusNode.hasFocus) {
      widget.onFocus(_controller);
    }
  }

  @override
  void didUpdateWidget(covariant TextBlockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.content != widget.block.content &&
        !widget.focusNode.hasFocus) {
      // Only update if external change and NOT focused (to avoid overwriting user typing)
      final delta = RichTextUtils.getDelta(widget.block.content);
      final currentSelection = _controller.selection;
      _controller.document = quill.Document.fromDelta(delta);
      _controller.updateSelection(currentSelection, quill.ChangeSource.local);
    }
  }

  void _onChanged() {
    final newContent = RichTextUtils.deltaToStorage(
      _controller.document.toDelta(),
    );
    // Simple debounce could be added here if needed, but for now propagate immediately
    if (newContent != widget.block.content) {
      widget.onContentChanged(newContent);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChanged);
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEditing) {
      // Read-only view
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: quill.QuillEditor.basic(
          controller: _controller,
          config: const quill.QuillEditorConfig(
            autoFocus: false,
            expands: false,
            padding: EdgeInsets.zero,
            scrollable: false,
            enableInteractiveSelection: false,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: quill.QuillEditor.basic(
              controller: _controller,
              focusNode: widget.focusNode,
              config: quill.QuillEditorConfig(
                autoFocus: false,
                expands: false,
                padding: EdgeInsets.zero,
                scrollable: false, // Let parent scroll
                placeholder: 'Type something...',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
