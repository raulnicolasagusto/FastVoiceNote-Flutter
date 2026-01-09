import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReminderModal extends StatefulWidget {
  final DateTime? initialDateTime;
  final Function(DateTime) onDateTimeSelected;

  const ReminderModal({
    super.key,
    this.initialDateTime,
    required this.onDateTimeSelected,
  });

  @override
  State<ReminderModal> createState() => _ReminderModalState();
}

class _ReminderModalState extends State<ReminderModal> {
  DateTime? selectedDateTime;
  
  @override
  void initState() {
    super.initState();
    selectedDateTime = widget.initialDateTime;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      MaterialLocalizations.of(context).cancelButtonLabel,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    'Set Reminder',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: selectedDateTime != null
                        ? () {
                            widget.onDateTimeSelected(selectedDateTime!);
                            Navigator.of(context).pop();
                          }
                        : null,
                    child: Text(
                      MaterialLocalizations.of(context).okButtonLabel,
                      style: TextStyle(
                        color: selectedDateTime != null
                            ? theme.colorScheme.primary
                            : Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: selectedDateTime ?? DateTime.now().add(const Duration(hours: 1)),
                  minimumDate: DateTime.now(),
                  maximumDate: DateTime.now().add(const Duration(days: 365)),
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      selectedDateTime = newDateTime;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
