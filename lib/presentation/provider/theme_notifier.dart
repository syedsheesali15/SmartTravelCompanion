import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kDarkKey = 'stc_dark_mode_enabled';

final class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier();

  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  Future<void> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_kDarkKey) ?? false;
    _mode = enabled ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> setDrawerDarkEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkKey, enabled);
    _mode = enabled ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
