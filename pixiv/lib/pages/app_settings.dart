import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static ThemeMode get themeMode {
    final themeModeStr = _prefs?.getString('themeMode') ?? 'system';
    switch (themeModeStr) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static set themeMode(ThemeMode themeMode) {
    _prefs?.setString('themeMode', themeMode.toString().split('.').last);
  }

  static Color get themeColor =>
      Color(_prefs?.getInt('themeColor') ?? Colors.blue.value);
  static set themeColor(Color color) =>
      _prefs?.setInt('themeColor', color.value);
}
