import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/sample_tasks.dart';
import 'data/task_repository.dart';
import 'state/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final repo = await HiveTaskRepository.open();
  final settingsBox = await Hive.openBox(SettingsProvider.boxName);

  // First launch: add a few example tasks so the app is not empty.
  if (settingsBox.get('seeded') != true) {
    if (repo.loadAll().isEmpty) await repo.saveAll(sampleTasks(DateTime.now()));
    await settingsBox.put('seeded', true);
  }

  runApp(TodoApp(repository: repo, settings: SettingsProvider(settingsBox)));
}
