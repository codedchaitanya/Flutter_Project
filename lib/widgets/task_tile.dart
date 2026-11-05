import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';

/// One task card: checkbox, title, note, chips for category / priority / due date.
/// Swipe left to edit or delete.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.now,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.dragHandleIndex,
  });

  final Task task;
  final DateTime now;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// When set, shows a drag handle for [ReorderableListView] at this index.
  final int? dragHandleIndex;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final overdue = task.isOverdueOn(now);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Slidable(
        key: ValueKey('slide-${task.id}'),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.45,
          children: [
            SlidableAction(
              onPressed: (_) => onEdit(),
              backgroundColor: scheme.secondaryContainer,
              foregroundColor: scheme.onSecondaryContainer,
              icon: Icons.edit_outlined,
              label: 'Edit',
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
            ),
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
              icon: Icons.delete_outline,
              label: 'Delete',
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(16)),
            ),
          ],
        ),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onEdit,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                      width: 5,
                      color: task.done
                          ? scheme.outlineVariant
                          : task.priority.color),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Center(
                      child: Checkbox(
                        value: task.done,
                        onChanged: (_) => onToggle(),
                        shape: const CircleBorder(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 8, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: text.titleMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration:
                                  task.done ? TextDecoration.lineThrough : null,
                              color:
                                  task.done ? scheme.outline : scheme.onSurface,
                            ),
                            child: Text(task.title,
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                          ),
                          if (task.note.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              task.note,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodySmall!
                                  .copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _Pill(
                                icon: task.category.icon,
                                label: task.category.label,
                                color: task.category.color,
                              ),
                              _Pill(
                                icon: Icons.flag_outlined,
                                label: task.priority.label,
                                color: task.priority.color,
                              ),
                              if (task.dueDate != null)
                                _Pill(
                                  icon: overdue
                                      ? Icons.warning_amber_rounded
                                      : Icons.event_outlined,
                                  label: _dueLabel(task.dueDate!, now, overdue),
                                  color:
                                      overdue ? scheme.error : scheme.primary,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (dragHandleIndex != null)
                    ReorderableDragStartListener(
                      index: dragHandleIndex!,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child:
                            Icon(Icons.drag_indicator, color: scheme.outline),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _dueLabel(DateTime due, DateTime now, bool overdue) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(due.year, due.month, due.day);
    final diff = day.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (overdue) return 'Overdue · ${DateFormat('d MMM').format(due)}';
    return DateFormat('EEE, d MMM').format(due);
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
