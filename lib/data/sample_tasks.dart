import '../models/task.dart';

/// A few example tasks shown on the very first launch, so the app is not empty.
List<Task> sampleTasks(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  var i = 0;
  Task t(String title,
      {String note = '',
      Priority p = Priority.medium,
      TaskCategory c = TaskCategory.personal,
      int? dueIn,
      bool done = false}) {
    final pos = i++;
    return Task(
      id: 'sample-$pos',
      title: title,
      note: note,
      priority: p,
      category: c,
      dueDate: dueIn == null ? null : today.add(Duration(days: dueIn)),
      done: done,
      completedAt: done ? now : null,
      createdAt: now,
      position: pos,
    );
  }

  return [
    t('Swipe left on a task to edit or delete it',
        c: TaskCategory.personal, p: Priority.low),
    t('Finish the sprint demo',
        note: 'Record a 2-minute walkthrough',
        p: Priority.high,
        c: TaskCategory.work,
        dueIn: 0),
    t('Revise graph algorithms',
        note: 'BFS, DFS, Dijkstra', c: TaskCategory.study, dueIn: 2),
    t('Evening run',
        note: '5 km', p: Priority.low, c: TaskCategory.health, dueIn: 1),
    t('Buy groceries',
        note: 'Milk, eggs, fruit', c: TaskCategory.shopping, dueIn: -1),
    t('Set up the project repo',
        p: Priority.high, c: TaskCategory.work, done: true),
    t('Pay the electricity bill', c: TaskCategory.personal, done: true),
  ];
}
