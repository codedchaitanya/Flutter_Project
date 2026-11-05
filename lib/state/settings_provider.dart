import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Remembers the chosen theme (system / light / dark) between launches.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider([this._box]) {
    final saved = _box?.get(_key) as String?;
    _themeMode = ThemeMode.values
        .firstWhere((m) => m.name == saved, orElse: () => ThemeMode.system);
  }

  static const boxName = 'settings';
  static const _key = 'themeMode';
  final Box? _box;
  late ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  static Future<SettingsProvider> open() async =>
      SettingsProvider(await Hive.openBox(boxName));

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    _box?.put(_key, mode.name);
  }
}
