import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../state/settings_provider.dart';
import '../state/task_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_editor_sheet.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _addTask(BuildContext context) async {
    final draft = await showTaskEditor(context);
    if (draft == null || !context.mounted) return;
    await context.read<TaskProvider>().addTask(
          title: draft.title,
          note: draft.note,
          priority: draft.priority,
          category: draft.category,
          dueDate: draft.dueDate,
        );
  }

  Future<void> _editTask(BuildContext context, Task task) async {
    final draft = await showTaskEditor(context, initial: task);
    if (draft == null || !context.mounted) return;
    await context.read<TaskProvider>().updateTask(task.copyWith(
          title: draft.title,
          note: draft.note,
          priority: draft.priority,
          category: draft.category,
          dueDate: draft.dueDate,
          clearDueDate: draft.dueDate == null,
        ));
  }

  void _deleteTask(BuildContext context, Task task) {
    final provider = context.read<TaskProvider>();
    provider.deleteTask(task.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Deleted "${task.title}"'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'UNDO', onPressed: provider.undoDelete),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = provider.visibleTasks;
    final now = provider.now;
    final reorder = provider.canReorder;

    Widget tile(Task t, int index) => TaskTile(
          key: ValueKey(t.id),
          task: t,
          now: now,
          dragHandleIndex: reorder ? index : null,
          onToggle: () => provider.toggleDone(t.id),
          onEdit: () => _editTask(context, t),
          onDelete: () => _deleteTask(context, t),
        );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Tasks'),
            Text(
              DateFormat('EEEE, d MMMM').format(now),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: const [_ThemeMenu(), _MoreMenu(), SizedBox(width: 8)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('addTask'),
        onPressed: () => _addTask(context),
        icon: const Icon(Icons.add),
        label: const Text('New task'),
      ),
      body: Column(
        children: [
          const _ProgressCard(),
          const _SearchField(),
          const _FilterBar(),
          Expanded(
            child: tasks.isEmpty
                ? EmptyState(
                    hasAnyTasks: provider.allTasks.isNotEmpty,
                  )
                : reorder
                    ? ReorderableListView.builder(
                        buildDefaultDragHandles: false,
                        padding: const EdgeInsets.only(top: 4, bottom: 96),
                        itemCount: tasks.length,
                        onReorderItem: provider.reorder,
                        itemBuilder: (_, i) => tile(tasks[i], i),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 4, bottom: 96),
                        itemCount: tasks.length,
                        itemBuilder: (_, i) => tile(tasks[i], i),
                      ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    final stats = context
        .select<TaskProvider, (int, int)>((p) => (p.stats.done, p.stats.total));
    final (done, total) = stats;
    final rate = total == 0 ? 0.0 : done / total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    total == 0
                        ? 'Nothing planned yet'
                        : '$done of $total tasks done',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: rate),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) => LinearProgressIndicator(
                        value: v,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${(rate * 100).round()}%',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: TextField(
        key: const Key('search'),
        onChanged: context.read<TaskProvider>().setQuery,
        decoration: const InputDecoration(
          hintText: 'Search tasks',
          prefixIcon: Icon(Icons.search),
          isDense: true,
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          for (final f in TaskFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f.label),
                selected: provider.filter == f,
                onSelected: (_) => provider.setFilter(f),
              ),
            ),
          const VerticalDivider(width: 16, indent: 6, endIndent: 6),
          for (final c in TaskCategory.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: Icon(c.icon, size: 16, color: c.color),
                label: Text(c.label),
                selected: provider.category == c,
                showCheckmark: false,
                onSelected: (sel) => provider.setCategory(sel ? c : null),
              ),
            ),
        ],
      ),
    );
  }
}

class _ThemeMenu extends StatelessWidget {
  const _ThemeMenu();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final icon = switch (settings.themeMode) {
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.dark => Icons.dark_mode_outlined,
      ThemeMode.system => Icons.brightness_auto_outlined,
    };
    return PopupMenuButton<ThemeMode>(
      tooltip: 'Theme',
      icon: Icon(icon),
      initialValue: settings.themeMode,
      onSelected: settings.setThemeMode,
      itemBuilder: (_) => const [
        PopupMenuItem(value: ThemeMode.system, child: Text('System theme')),
        PopupMenuItem(value: ThemeMode.light, child: Text('Light')),
        PopupMenuItem(value: ThemeMode.dark, child: Text('Dark')),
      ],
    );
  }
}

class _MoreMenu extends StatelessWidget {
  const _MoreMenu();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'More',
      onSelected: (v) async {
        if (v != 'clear') return;
        final provider = context.read<TaskProvider>();
        final count = provider.stats.done;
        if (count == 0) return;
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Clear completed?'),
            content: Text(
                'This removes $count completed ${count == 1 ? 'task' : 'tasks'}.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Clear')),
            ],
          ),
        );
        if (ok == true) await provider.clearCompleted();
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'clear', child: Text('Clear completed')),
      ],
    );
  }
}
