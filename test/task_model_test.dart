import 'package:flutter_test/flutter_test.dart';
import 'package:todoapp/models/task.dart';

void main() {
  final created = DateTime(2026, 1, 10, 9);

  group('Task', () {
    test('toMap / fromMap round trip keeps every field', () {
      final task = Task(
        id: 'a1',
        title: 'Write tests',
        note: 'unit + widget',
        done: true,
        priority: Priority.high,
        category: TaskCategory.work,
        dueDate: DateTime(2026, 1, 12),
        createdAt: created,
        completedAt: DateTime(2026, 1, 11),
        position: 3,
      );
      expect(Task.fromMap(task.toMap()), task);
    });

    test('fromMap falls back to defaults for missing or unknown values', () {
      final task =
          Task.fromMap({'id': 'x', 'title': 'Old task', 'priority': 'urgent'});
      expect(task.priority, Priority.medium);
      expect(task.category, TaskCategory.personal);
      expect(task.done, isFalse);
      expect(task.dueDate, isNull);
    });

    test('overdue only when not done and due before today', () {
      final now = DateTime(2026, 1, 10, 18);
      final t = Task(
          id: '1',
          title: 't',
          createdAt: created,
          dueDate: DateTime(2026, 1, 9));
      expect(t.isOverdueOn(now), isTrue);
      expect(t.copyWith(done: true).isOverdueOn(now), isFalse);
      expect(
          t.copyWith(dueDate: DateTime(2026, 1, 10)).isOverdueOn(now), isFalse,
          reason: 'due today is not overdue');
      expect(t.copyWith(clearDueDate: true).isOverdueOn(now), isFalse);
    });

    test('copyWith can clear the due date', () {
      final t = Task(
          id: '1',
          title: 't',
          createdAt: created,
          dueDate: DateTime(2026, 2, 1));
      expect(t.copyWith(clearDueDate: true).dueDate, isNull);
      expect(t.copyWith(title: 'new').dueDate, DateTime(2026, 2, 1));
    });
  });
}
