import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/checklist_item.dart';
import '../models/checklist_utils.dart';
import '../../../core/l10n/generated/app_localizations.dart';

class ChecklistWidget extends StatefulWidget {
  final List<ChecklistItem> items;
  final Function(List<ChecklistItem>) onItemsChanged;
  final bool isEditing;
  final VoidCallback? onEditModeRequested;

  const ChecklistWidget({
    super.key,
    required this.items,
    required this.onItemsChanged,
    this.isEditing = false,
    this.onEditModeRequested,
  });

  @override
  State<ChecklistWidget> createState() => _ChecklistWidgetState();
}

class _ChecklistWidgetState extends State<ChecklistWidget> {
  late List<ChecklistItem> _items;
  late bool _isEditing;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    _isEditing = widget.isEditing;
    _initializeControllers();
  }

  @override
  void didUpdateWidget(ChecklistWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _items = List.from(widget.items);
      _initializeControllers();
    }
    if (oldWidget.isEditing != widget.isEditing) {
      _isEditing = widget.isEditing;
    }
  }

  void _initializeControllers() {
    // Dispose old controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();

    // Create new controllers
    for (var item in _items) {
      _controllers[item.id] = TextEditingController(text: item.text);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateItems() {
    widget.onItemsChanged(_items);
  }

  void _toggleCheck(String itemId) {
    setState(() {
      final index = _items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        _items[index] = _items[index].copyWith(isChecked: !_items[index].isChecked);
        _updateItems();
      }
    });
  }

  void _addItem() {
    setState(() {
      final newId = ChecklistUtils.generateItemId();
      final newItem = ChecklistItem(id: newId, text: '');
      _items.add(newItem);
      _controllers[newId] = TextEditingController(text: '');
      _isEditing = true;
      _updateItems();
      
      // Focus on the new item after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controllers[newId]?.selection = TextSelection.fromPosition(
          TextPosition(offset: _controllers[newId]!.text.length),
        );
      });
    });
  }

  void _deleteItem(String itemId) {
    setState(() {
      _controllers[itemId]?.dispose();
      _controllers.remove(itemId);
      _items.removeWhere((item) => item.id == itemId);
      _updateItems();
    });
  }

  void _updateItemText(String itemId, String text) {
    setState(() {
      final index = _items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        _items[index] = _items[index].copyWith(text: text);
        _updateItems();
      }
    });
  }

  void _onItemTap(String itemId) {
    if (!_isEditing) {
      widget.onEditModeRequested?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Checklist Items
        ...List.generate(_items.length, (index) {
          final item = _items[index];
          final controller = _controllers[item.id]!;

          return _ChecklistItemWidget(
            item: item,
            controller: controller,
            isEditing: _isEditing,
            isDark: isDark,
            onTap: () => _onItemTap(item.id),
            onCheckChanged: () => _toggleCheck(item.id),
            onTextChanged: (text) => _updateItemText(item.id, text),
            onDelete: () => _deleteItem(item.id),
            onEditModeRequested: widget.onEditModeRequested,
          );
        }),

        // Add Item Button (only in editing mode)
        if (_isEditing)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: InkWell(
              onTap: _addItem,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.transparent,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add,
                      color: colors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.addItem,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ChecklistItemWidget extends StatefulWidget {
  final ChecklistItem item;
  final TextEditingController controller;
  final bool isEditing;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onCheckChanged;
  final Function(String) onTextChanged;
  final VoidCallback onDelete;
  final VoidCallback? onEditModeRequested;

  const _ChecklistItemWidget({
    required this.item,
    required this.controller,
    required this.isEditing,
    required this.isDark,
    required this.onTap,
    required this.onCheckChanged,
    required this.onTextChanged,
    required this.onDelete,
    this.onEditModeRequested,
  });

  @override
  State<_ChecklistItemWidget> createState() => _ChecklistItemWidgetState();
}

class _ChecklistItemWidgetState extends State<_ChecklistItemWidget> {
  bool _isEditingText = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textColor = widget.isDark ? colors.onSurface : Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Checkbox
          Checkbox(
            value: widget.item.isChecked,
            onChanged: widget.isEditing ? null : (value) => widget.onCheckChanged(),
            activeColor: colors.primary,
          ),
          const SizedBox(width: 8),
          // Text field or text
          Expanded(
            child: widget.isEditing || _isEditingText
                ? TextField(
                    controller: widget.controller,
                    autofocus: _isEditingText && !widget.isEditing,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: widget.item.isChecked && !widget.isEditing
                          ? textColor.withValues(alpha: 0.5)
                          : textColor,
                      decoration: widget.item.isChecked && !widget.isEditing
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                    ),
                    onChanged: widget.onTextChanged,
                    onTap: () {
                      if (!_isEditingText && !widget.isEditing) {
                        widget.onEditModeRequested?.call();
                        setState(() {
                          _isEditingText = true;
                        });
                        widget.onTap();
                      }
                    },
                    onTapOutside: (event) {
                      if (_isEditingText && !widget.isEditing) {
                        setState(() {
                          _isEditingText = false;
                        });
                      }
                    },
                    onSubmitted: (value) {
                      if (!widget.isEditing) {
                        setState(() {
                          _isEditingText = false;
                        });
                      }
                    },
                  )
                : GestureDetector(
                    onTap: widget.onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        widget.item.text.isEmpty ? ' ' : widget.item.text,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: widget.item.isChecked
                              ? textColor.withValues(alpha: 0.5)
                              : textColor,
                          decoration: widget.item.isChecked
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                  ),
          ),
          // Delete button (only in editing mode)
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: textColor.withValues(alpha: 0.6),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: widget.onDelete,
            ),
        ],
      ),
    );
  }
}
