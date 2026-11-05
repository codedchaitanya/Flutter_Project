import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';

/// What the editor returns when the user saves.
class TaskDraft {
  const TaskDraft({
    required this.title,
    required this.note,
    required this.priority,
    required this.category,
    required this.dueDate,
  });

  final String title;
  final String note;
  final Priority priority;
  final TaskCategory category;
  final DateTime? dueDate;
}

/// Bottom sheet to add a new task or edit an existing one ([initial]).
Future<TaskDraft?> showTaskEditor(BuildContext context, {Task? initial}) {
  return showModalBottomSheet<TaskDraft>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => TaskEditorSheet(initial: initial),
  );
}

class TaskEditorSheet extends StatefulWidget {
  const TaskEditorSheet({super.key, this.initial});

  final Task? initial;

  @override
  State<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<TaskEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _note;
  late Priority _priority;
  late TaskCategory _category;
  DateTime? _due;

  bool get _editing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    _title = TextEditingController(text: t?.title ?? '');
    _note = TextEditingController(text: t?.note ?? '');
    _priority = t?.priority ?? Priority.medium;
    _category = t?.category ?? TaskCategory.personal;
    _due = t?.dueDate;
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _due ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _due = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(TaskDraft(
      title: _title.text.trim(),
      note: _note.text.trim(),
      priority: _priority,
      category: _category,
      dueDate: _due,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_editing ? 'Edit task' : 'New task', style: text.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('titleField'),
                controller: _title,
                autofocus: !_editing,
                textCapitalization: TextCapitalization.sentences,
                decoration:
                    const InputDecoration(hintText: 'What needs to be done?'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter a title'
                    : null,
                onFieldSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _note,
                minLines: 1,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Notes (optional)'),
              ),
              const SizedBox(height: 20),
              Text('Priority', style: text.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<Priority>(
                showSelectedIcon: false,
                segments: [
                  for (final p in Priority.values)
                    ButtonSegment(
                      value: p,
                      label: Text(p.label),
                      icon: Icon(Icons.flag, color: p.color, size: 18),
                    ),
                ],
                selected: {_priority},
                onSelectionChanged: (s) => setState(() => _priority = s.first),
              ),
              const SizedBox(height: 20),
              Text('Category', style: text.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in TaskCategory.values)
                    ChoiceChip(
                      avatar: Icon(c.icon, size: 18, color: c.color),
                      label: Text(c.label),
                      selected: _category == c,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _category = c),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Due date', style: text.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.event_outlined),
                    label: Text(_due == null
                        ? 'Pick a date'
                        : DateFormat('EEE, d MMM y').format(_due!)),
                  ),
                  if (_due != null)
                    IconButton(
                      tooltip: 'Remove due date',
                      onPressed: () => setState(() => _due = null),
                      icon: const Icon(Icons.close),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('saveTask'),
                  onPressed: _save,
                  icon: Icon(_editing ? Icons.check : Icons.add),
                  label: Text(_editing ? 'Save changes' : 'Add task'),
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
