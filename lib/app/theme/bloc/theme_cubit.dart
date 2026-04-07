import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themeKey = 'theme_mode';
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(ThemeMode.light) {
    _loadTheme();
  }

  void _loadTheme() {
    final themeIndex = _prefs.getInt(_themeKey);
    if (themeIndex != null) {
      emit(ThemeMode.values[themeIndex]);
    }
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _prefs.setInt(_themeKey, newMode.index);
    emit(newMode);
  }

  bool get isDarkMode => state == ThemeMode.dark;
}
