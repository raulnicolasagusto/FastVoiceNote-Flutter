import 'package:flutter/material.dart';
import '../../models/note_block.dart';
import '../../models/checklist_item.dart';
import '../checklist_widget.dart';

class ChecklistBlockWidget extends StatefulWidget {
  final ChecklistBlock block;
  final Function(List<ChecklistItem>) onItemsChanged;
  final VoidCallback onDelete;
  final FocusNode focusNode; // To focus the first/last item if needed
  final bool isEditing;

  const ChecklistBlockWidget({
    super.key,
    required this.block,
    required this.onItemsChanged,
    required this.onDelete,
    required this.focusNode,
    this.isEditing = true,
  });

  @override
  State<ChecklistBlockWidget> createState() => _ChecklistBlockWidgetState();
}

class _ChecklistBlockWidgetState extends State<ChecklistBlockWidget> {
  // We can reuse the existing ChecklistWidget logic
  // We just need to make sure it propagates changes back up correctly

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ChecklistWidget(
          items: widget.block.items,
          onItemsChanged: widget.onItemsChanged,
          isEditing: widget.isEditing,
          // We might need to expose onEditModeRequested to parent if we want tap-to-edit behavior
          // For now, let's assume if the note is editable, the checklist is too
          onEditModeRequested: () {},
        ),
        if (widget.isEditing)
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.grey,
              onPressed: widget.onDelete,
              tooltip: 'Remove Checklist',
            ),
          ),
      ],
    );
  }
}
