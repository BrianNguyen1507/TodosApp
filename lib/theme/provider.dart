import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/theme/theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightmode;
  static const String _themePreferenceKey = 'themePreference';
  ThemeData get themeData => _themeData;
  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? themePreference = prefs.getInt(_themePreferenceKey);
    if (themePreference != null) {
      _themeData = themePreference == 0 ? lightmode : darkmode;
    }
    notifyListeners();
  }

  void _saveThemePreference(int themePreference) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(_themePreferenceKey, themePreference);
  }

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    _saveThemePreference(1);
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightmode) {
      _themeData = darkmode;
      _saveThemePreference(1);
    } else {
      _themeData = lightmode;
      _saveThemePreference(0);
    }
    notifyListeners();
  }
}
