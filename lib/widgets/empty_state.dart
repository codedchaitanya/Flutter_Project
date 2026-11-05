import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.hasAnyTasks});

  /// True when tasks exist but the current filter / search hides them all.
  final bool hasAnyTasks;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: scheme.primaryContainer, shape: BoxShape.circle),
              child: Icon(
                hasAnyTasks ? Icons.filter_alt_off_outlined : Icons.task_alt,
                size: 48,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasAnyTasks ? 'No matching tasks' : 'All clear!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              hasAnyTasks
                  ? 'Try another filter or search.'
                  : 'Tap "New task" to plan your day.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
