import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/task_repository.dart';
import 'screens/shell.dart';
import 'state/settings_provider.dart';
import 'state/task_provider.dart';
import 'theme/app_theme.dart';

class TodoApp extends StatelessWidget {
  const TodoApp(
      {super.key,
      required this.repository,
      required this.settings,
      this.clock});

  final TaskRepository repository;
  final SettingsProvider settings;

  /// Lets tests fix "today".
  final DateTime Function()? clock;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => TaskProvider(repository, clock: clock)),
        ChangeNotifierProvider.value(value: settings),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, s, _) => MaterialApp(
          title: 'Taskly',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: s.themeMode,
          home: const Shell(),
        ),
      ),
    );
  }
}
