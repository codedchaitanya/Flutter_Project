import 'package:flutter_test/flutter_test.dart';
import 'package:todoapp/data/task_repository.dart';
import 'package:todoapp/models/task.dart';
import 'package:todoapp/state/task_provider.dart';

void main() {
  final now = DateTime(2026, 3, 15, 10);
  late InMemoryTaskRepository repo;
  late TaskProvider provider;

  setUp(() {
    repo = InMemoryTaskRepository();
    provider = TaskProvider(repo, clock: () => now);
  });

  test('addTask puts the new task on top and saves it', () async {
    await provider.addTask(title: 'First');
    await provider.addTask(title: '  Second  ');
    expect(provider.visibleTasks.map((t) => t.title), ['Second', 'First']);
    expect(repo.loadAll(), hasLength(2));
  });

  test('toggleDone sets and clears completedAt', () async {
    final t = await provider.addTask(title: 'Task');
    await provider.toggleDone(t.id);
    expect(provider.allTasks.single.done, isTrue);
    expect(provider.allTasks.single.completedAt, now);
    await provider.toggleDone(t.id);
    expect(provider.allTasks.single.done, isFalse);
    expect(provider.allTasks.single.completedAt, isNull);
  });

  test('delete then undo restores the task at the same place', () async {
    await provider.addTask(title: 'C');
    final b = await provider.addTask(title: 'B');
    await provider.addTask(title: 'A');
    await provider.deleteTask(b.id);
    expect(provider.allTasks.map((t) => t.title), ['A', 'C']);
    expect(repo.loadAll(), hasLength(2));

    await provider.undoDelete();
    expect(provider.allTasks.map((t) => t.title), ['A', 'B', 'C']);
    expect(repo.loadAll(), hasLength(3));
    expect(provider.canUndo, isFalse);
  });

  test('filters, category and search combine', () async {
    final a = await provider.addTask(
        title: 'Gym',
        category: TaskCategory.health,
        dueDate: DateTime(2026, 3, 15));
    await provider.addTask(
        title: 'Report',
        category: TaskCategory.work,
        dueDate: DateTime(2026, 3, 14));
    await provider.addTask(
        title: 'Read book', note: 'gym bag', category: TaskCategory.personal);
    await provider.toggleDone(a.id);

    provider.setFilter(TaskFilter.done);
    expect(provider.visibleTasks.map((t) => t.title), ['Gym']);

    provider.setFilter(TaskFilter.overdue);
    expect(provider.visibleTasks.map((t) => t.title), ['Report']);

    provider.setFilter(TaskFilter.today);
    expect(provider.visibleTasks.map((t) => t.title), ['Gym']);

    provider.setFilter(TaskFilter.all);
    provider.setQuery('GYM');
    expect(provider.visibleTasks.map((t) => t.title), ['Read book', 'Gym'],
        reason: 'search looks at notes too');

    provider.setCategory(TaskCategory.health);
    expect(provider.visibleTasks.map((t) => t.title), ['Gym']);
    expect(provider.canReorder, isFalse);
  });

  test('reorder moves a task and persists positions', () async {
    await provider.addTask(title: 'C');
    await provider.addTask(title: 'B');
    await provider.addTask(title: 'A');
    await provider.reorder(0, 2); // A to the bottom
    expect(provider.allTasks.map((t) => t.title), ['B', 'C', 'A']);

    final reloaded = TaskProvider(repo, clock: () => now);
    expect(reloaded.allTasks.map((t) => t.title), ['B', 'C', 'A']);
  });

  test('stats count done, overdue, due today and priorities', () async {
    await provider.addTask(
        title: 'late', priority: Priority.high, dueDate: DateTime(2026, 3, 1));
    await provider.addTask(
        title: 'today', priority: Priority.low, dueDate: DateTime(2026, 3, 15));
    final done = await provider.addTask(title: 'done', priority: Priority.high);
    await provider.toggleDone(done.id);

    final s = provider.stats;
    expect(s.total, 3);
    expect(s.done, 1);
    expect(s.overdue, 1);
    expect(s.dueToday, 1);
    expect(s.activeByPriority[Priority.high], 1);
    expect(s.activeByPriority[Priority.low], 1);
    expect(s.completionRate, closeTo(1 / 3, 1e-9));
  });

  test('clearCompleted removes only done tasks', () async {
    final a = await provider.addTask(title: 'a');
    await provider.addTask(title: 'b');
    await provider.toggleDone(a.id);
    await provider.clearCompleted();
    expect(provider.allTasks.map((t) => t.title), ['b']);
    expect(repo.loadAll().map((t) => t.title), ['b']);
  });
}
