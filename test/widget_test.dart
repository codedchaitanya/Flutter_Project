import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todoapp/app.dart';
import 'package:todoapp/data/task_repository.dart';
import 'package:todoapp/models/task.dart';
import 'package:todoapp/state/settings_provider.dart';

void main() {
  final now = DateTime(2026, 3, 15, 10);

  Future<InMemoryTaskRepository> pumpApp(WidgetTester tester,
      [List<Task> tasks = const []]) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    final repo = InMemoryTaskRepository(tasks);
    await tester.pumpWidget(TodoApp(
        repository: repo, settings: SettingsProvider(), clock: () => now));
    await tester.pumpAndSettle();
    return repo;
  }

  testWidgets('empty app shows the empty state', (tester) async {
    await pumpApp(tester);
    expect(find.text('All clear!'), findsOneWidget);
    expect(find.text('Nothing planned yet'), findsOneWidget);
  });

  testWidgets('add a task through the editor sheet', (tester) async {
    final repo = await pumpApp(tester);

    await tester.tap(find.byKey(const Key('addTask')));
    await tester.pumpAndSettle();

    // Saving an empty title shows a validation error.
    await tester.tap(find.byKey(const Key('saveTask')));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a title'), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('titleField')), 'Prepare for interview');
    await tester.tap(find.text('High'));
    await tester.tap(find.text('Work'));
    await tester.tap(find.byKey(const Key('saveTask')));
    await tester.pumpAndSettle();

    expect(find.text('Prepare for interview'), findsOneWidget);
    expect(find.text('0 of 1 tasks done'), findsOneWidget);
    final saved = repo.loadAll().single;
    expect(saved.priority, Priority.high);
    expect(saved.category, TaskCategory.work);
  });

  testWidgets('ticking the checkbox completes a task and updates progress',
      (tester) async {
    await pumpApp(tester, [Task(id: '1', title: 'Buy milk', createdAt: now)]);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(find.text('1 of 1 tasks done'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('search narrows the list', (tester) async {
    await pumpApp(tester, [
      Task(id: '1', title: 'Buy milk', createdAt: now, position: 0),
      Task(id: '2', title: 'Call mom', createdAt: now, position: 1),
    ]);
    await tester.enterText(find.byKey(const Key('search')), 'milk');
    await tester.pumpAndSettle();
    expect(find.text('Buy milk'), findsOneWidget);
    expect(find.text('Call mom'), findsNothing);
  });

  testWidgets('stats tab shows totals', (tester) async {
    await pumpApp(tester, [
      Task(id: '1', title: 'a', createdAt: now, done: true),
      Task(id: '2', title: 'b', createdAt: now, dueDate: DateTime(2026, 3, 1)),
    ]);
    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.text('Completion'), findsOneWidget);
    expect(find.text('1 done, 1 to go.'), findsOneWidget);
    expect(find.text('Overdue'), findsWidgets);
  });
}
