import 'package:hive_flutter/hive_flutter.dart';

import '../models/task.dart';

/// Where tasks are stored. The app uses [HiveTaskRepository];
/// tests use [InMemoryTaskRepository] so they need no disk.
abstract class TaskRepository {
  List<Task> loadAll();
  Future<void> save(Task task);
  Future<void> saveAll(Iterable<Task> tasks);
  Future<void> delete(String id);
}

/// Stores each task as a plain map in a Hive box (works on Android, iOS, desktop and web).
class HiveTaskRepository implements TaskRepository {
  HiveTaskRepository(this._box);

  static const boxName = 'tasks';
  final Box<Map> _box;

  static Future<HiveTaskRepository> open() async {
    final box = await Hive.openBox<Map>(boxName);
    return HiveTaskRepository(box);
  }

  @override
  List<Task> loadAll() => _box.values.map(Task.fromMap).toList();

  @override
  Future<void> save(Task task) => _box.put(task.id, task.toMap());

  @override
  Future<void> saveAll(Iterable<Task> tasks) =>
      _box.putAll({for (final t in tasks) t.id: t.toMap()});

  @override
  Future<void> delete(String id) => _box.delete(id);
}

class InMemoryTaskRepository implements TaskRepository {
  InMemoryTaskRepository([Iterable<Task> initial = const []]) {
    for (final t in initial) {
      _store[t.id] = t;
    }
  }

  final Map<String, Task> _store = {};

  @override
  List<Task> loadAll() => _store.values.toList();

  @override
  Future<void> save(Task task) async => _store[task.id] = task;

  @override
  Future<void> saveAll(Iterable<Task> tasks) async {
    for (final t in tasks) {
      _store[t.id] = t;
    }
  }

  @override
  Future<void> delete(String id) async => _store.remove(id);
}
