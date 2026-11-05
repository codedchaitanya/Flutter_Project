import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/task_repository.dart';
import '../models/task.dart';

enum TaskFilter { all, active, done, today, overdue }

extension TaskFilterLabel on TaskFilter {
  String get label => switch (this) {
        TaskFilter.all => 'All',
        TaskFilter.active => 'Active',
        TaskFilter.done => 'Done',
        TaskFilter.today => 'Today',
        TaskFilter.overdue => 'Overdue',
      };
}

/// Summary numbers for the stats screen.
class TaskStats {
  const TaskStats({
    required this.total,
    required this.done,
    required this.overdue,
    required this.dueToday,
    required this.activeByPriority,
    required this.byCategory,
  });

  final int total;
  final int done;
  final int overdue;
  final int dueToday;
  final Map<Priority, int> activeByPriority;
  final Map<TaskCategory, int> byCategory;

  int get active => total - done;
  double get completionRate => total == 0 ? 0 : done / total;
}

/// Holds the task list, the current filter / search, and every change to tasks.
class TaskProvider extends ChangeNotifier {
  TaskProvider(this._repo, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now {
    _tasks = _repo.loadAll()..sort((a, b) => a.position.compareTo(b.position));
  }

  final TaskRepository _repo;
  final DateTime Function() _clock;
  final _random = Random();

  late List<Task> _tasks;
  TaskFilter _filter = TaskFilter.all;
  TaskCategory? _category;
  String _query = '';

  /// The last deleted task and where it was, so it can be undone.
  (Task, int)? _lastDeleted;

  DateTime get now => _clock();
  TaskFilter get filter => _filter;
  TaskCategory? get category => _category;
  String get query => _query;
  List<Task> get allTasks => List.unmodifiable(_tasks);
  bool get canUndo => _lastDeleted != null;

  /// Tasks after filter, category and search. Order is the manual (drag-and-drop) order.
  List<Task> get visibleTasks {
    final now = _clock();
    final q = _query.trim().toLowerCase();
    return _tasks.where((t) {
      final passesFilter = switch (_filter) {
        TaskFilter.all => true,
        TaskFilter.active => !t.done,
        TaskFilter.done => t.done,
        TaskFilter.today => t.isDueOn(now),
        TaskFilter.overdue => t.isOverdueOn(now),
      };
      if (!passesFilter) return false;
      if (_category != null && t.category != _category) return false;
      if (q.isEmpty) return true;
      return t.title.toLowerCase().contains(q) ||
          t.note.toLowerCase().contains(q);
    }).toList();
  }

  /// Drag-and-drop is only offered when the full, unfiltered list is shown.
  bool get canReorder =>
      _filter == TaskFilter.all && _category == null && _query.trim().isEmpty;

  void setFilter(TaskFilter f) {
    _filter = f;
    notifyListeners();
  }

  void setCategory(TaskCategory? c) {
    _category = c;
    notifyListeners();
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  String _newId() =>
      '${_clock().microsecondsSinceEpoch.toRadixString(36)}${_random.nextInt(0x7fffffff).toRadixString(36)}';

  Future<Task> addTask({
    required String title,
    String note = '',
    Priority priority = Priority.medium,
    TaskCategory category = TaskCategory.personal,
    DateTime? dueDate,
  }) async {
    final minPos =
        _tasks.isEmpty ? 0 : _tasks.map((t) => t.position).reduce(min);
    final task = Task(
      id: _newId(),
      title: title.trim(),
      note: note.trim(),
      priority: priority,
      category: category,
      dueDate: dueDate,
      createdAt: _clock(),
      position: minPos - 1, // new tasks go to the top
    );
    _tasks.insert(0, task);
    notifyListeners();
    await _repo.save(task);
    return task;
  }

  Future<void> updateTask(Task updated) async {
    final i = _tasks.indexWhere((t) => t.id == updated.id);
    if (i == -1) return;
    _tasks[i] = updated;
    notifyListeners();
    await _repo.save(updated);
  }

  Future<void> toggleDone(String id) async {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i == -1) return;
    final t = _tasks[i];
    final updated = t.done
        ? t.copyWith(done: false, clearCompletedAt: true)
        : t.copyWith(done: true, completedAt: _clock());
    await updateTask(updated);
  }

  Future<void> deleteTask(String id) async {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i == -1) return;
    _lastDeleted = (_tasks.removeAt(i), i);
    notifyListeners();
    await _repo.delete(id);
  }

  Future<void> undoDelete() async {
    final last = _lastDeleted;
    if (last == null) return;
    final (task, index) = last;
    _tasks.insert(min(index, _tasks.length), task);
    _lastDeleted = null;
    notifyListeners();
    await _repo.save(task);
  }

  Future<void> clearCompleted() async {
    final doneIds = _tasks.where((t) => t.done).map((t) => t.id).toList();
    _tasks.removeWhere((t) => t.done);
    _lastDeleted = null;
    notifyListeners();
    for (final id in doneIds) {
      await _repo.delete(id);
    }
  }

  /// Moves a task in the full list; [newIndex] is its final position (as given by onReorderItem).
  Future<void> reorder(int oldIndex, int newIndex) async {
    final task = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, task);
    _tasks = [
      for (var i = 0; i < _tasks.length; i++) _tasks[i].copyWith(position: i)
    ];
    notifyListeners();
    await _repo.saveAll(_tasks);
  }

  TaskStats get stats {
    final now = _clock();
    final done = _tasks.where((t) => t.done).length;
    return TaskStats(
      total: _tasks.length,
      done: done,
      overdue: _tasks.where((t) => t.isOverdueOn(now)).length,
      dueToday: _tasks.where((t) => !t.done && t.isDueOn(now)).length,
      activeByPriority: {
        for (final p in Priority.values)
          p: _tasks.where((t) => !t.done && t.priority == p).length,
      },
      byCategory: {
        for (final c in TaskCategory.values)
          c: _tasks.where((t) => t.category == c).length,
      },
    );
  }
}
