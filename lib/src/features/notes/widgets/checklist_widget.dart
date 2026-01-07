import 'dart:async';
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
  final String searchQuery;

  const ChecklistWidget({
    super.key,
    required this.items,
    required this.onItemsChanged,
    this.isEditing = false,
    this.onEditModeRequested,
    this.searchQuery = '',
  });

  @override
  State<ChecklistWidget> createState() => _ChecklistWidgetState();
}

class _ChecklistWidgetState extends State<ChecklistWidget> {
  late List<ChecklistItem> _items;
  late bool _isEditing;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  Timer? _debounceTimer;

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
    
    // Solo actualizar si cambió el modo de edición
    if (oldWidget.isEditing != widget.isEditing) {
      _isEditing = widget.isEditing;
    }
    
    // Solo reinicializar si los items cambiaron desde FUERA (no por edición interna)
    // Comparamos por referencia para evitar actualizaciones cuando editamos internamente
    if (!identical(oldWidget.items, widget.items) && !identical(widget.items, _items)) {
      _syncWithExternalChanges();
    }
  }

  void _syncWithExternalChanges() {
    final newItems = List<ChecklistItem>.from(widget.items);
    final oldIds = _items.map((i) => i.id).toSet();
    final newIds = newItems.map((i) => i.id).toSet();
    
    // Eliminar controllers de items que ya no existen
    for (var id in oldIds.difference(newIds)) {
      _controllers[id]?.dispose();
      _controllers.remove(id);
      _focusNodes[id]?.dispose();
      _focusNodes.remove(id);
    }
    
    // Crear controllers para items nuevos O actualizar texto si cambió externamente
    for (var item in newItems) {
      if (!_controllers.containsKey(item.id)) {
        // Item nuevo - crear controller
        _controllers[item.id] = TextEditingController(text: item.text);
        _focusNodes[item.id] = FocusNode();
      } else {
        // Item existente - solo actualizar si el texto cambió y no está enfocado
        final controller = _controllers[item.id]!;
        final focusNode = _focusNodes[item.id]!;
        
        // Solo actualizar si no tiene foco (no está siendo editado)
        if (!focusNode.hasFocus && controller.text != item.text) {
          // Guardar posición del cursor por si acaso
          final selection = controller.selection;
          controller.text = item.text;
          
          // Restaurar selección si es válida
          if (selection.isValid && selection.end <= item.text.length) {
            controller.selection = selection;
          }
        }
      }
    }
    
    _items = newItems;
  }

  void _initializeControllers() {
    // Create controllers and focus nodes for all items
    for (var item in _items) {
      _controllers[item.id] = TextEditingController(text: item.text);
      _focusNodes[item.id] = FocusNode();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
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
      _focusNodes[newId] = FocusNode();
      _isEditing = true;
      _updateItems();
      
      // Focus on the new item after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[newId]?.requestFocus();
      });
    });
  }

  void _deleteItem(String itemId) {
    setState(() {
      _controllers[itemId]?.dispose();
      _controllers.remove(itemId);
      _focusNodes[itemId]?.dispose();
      _focusNodes.remove(itemId);
      _items.removeWhere((item) => item.id == itemId);
      _updateItems();
    });
  }

  void _updateItemText(String itemId, String text) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(text: text);
      
      // Usar debounce para actualizar el provider (500ms)
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        widget.onItemsChanged(_items);
      });
    }
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
    // Get text color from the Theme (which is set based on note background)
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Checklist Items
        ...List.generate(_items.length, (index) {
          final item = _items[index];
          final controller = _controllers[item.id]!;
          final focusNode = _focusNodes[item.id]!;

          return _ChecklistItemWidget(
            key: ValueKey(item.id),
            item: item,
            controller: controller,
            focusNode: focusNode,
            isEditing: _isEditing,
            textColor: textColor,
            onTap: () => _onItemTap(item.id),
            onCheckChanged: () => _toggleCheck(item.id),
            onTextChanged: (text) => _updateItemText(item.id, text),
            onDelete: () => _deleteItem(item.id),
            onEditModeRequested: widget.onEditModeRequested,
            searchQuery: widget.searchQuery,
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
  final FocusNode focusNode;
  final bool isEditing;
  final Color textColor;
  final VoidCallback onTap;
  final VoidCallback onCheckChanged;
  final Function(String) onTextChanged;
  final VoidCallback onDelete;
  final VoidCallback? onEditModeRequested;
  final String searchQuery;

  const _ChecklistItemWidget({
    super.key,
    required this.item,
    required this.controller,
    required this.focusNode,
    required this.isEditing,
    required this.textColor,
    required this.onTap,
    required this.onCheckChanged,
    required this.onTextChanged,
    required this.onDelete,
    this.onEditModeRequested,
    this.searchQuery = '',
  });

  @override
  State<_ChecklistItemWidget> createState() => _ChecklistItemWidgetState();
}

class _ChecklistItemWidgetState extends State<_ChecklistItemWidget> {
  bool _isEditingText = false;

  TextSpan _buildHighlightedText(String text, TextStyle style, Color highlightColor) {
    final searchQuery = widget.searchQuery.toLowerCase();
    if (searchQuery.isEmpty) {
      return TextSpan(text: text, style: style);
    }

    final List<TextSpan> spans = [];
    final lowerText = text.toLowerCase();
    int currentIndex = 0;

    while (currentIndex < text.length) {
      final index = lowerText.indexOf(searchQuery, currentIndex);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(currentIndex), style: style));
        break;
      }

      // Add text before match
      if (index > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, index), style: style));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + searchQuery.length),
        style: style.copyWith(
          backgroundColor: highlightColor,
          color: Colors.black87,
        ),
      ));

      currentIndex = index + searchQuery.length;
    }

    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textColor = widget.textColor;

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
            checkColor: Colors.white,
            side: BorderSide(color: textColor, width: 2),
          ),
          const SizedBox(width: 8),
          // Text field or text
          Expanded(
            child: widget.isEditing || _isEditingText
                ? TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
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
                      child: RichText(
                        text: _buildHighlightedText(
                          widget.item.text.isEmpty ? ' ' : widget.item.text,
                          GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: widget.item.isChecked
                                ? textColor.withValues(alpha: 0.5)
                                : textColor,
                            decoration: widget.item.isChecked
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          Colors.yellow.shade300,
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
