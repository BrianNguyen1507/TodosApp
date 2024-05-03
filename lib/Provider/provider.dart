import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/theme/theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightmode;
  Locale _locale = const Locale('en');

  static const String _themePreferenceKey = 'themePreference';
  static const String _localePreferenceKey = 'localePreference';

  ThemeData get themeData => _themeData;
  Locale get locale => _locale;

  String get languageDisplayText {
    return _locale.languageCode == 'en' ? 'Eng' : 'Vie';
  }

  ThemeProvider() {
    _loadTheme();
    _loadLocale();
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? themePreference = prefs.getInt(_themePreferenceKey);
    if (themePreference != null) {
      _themeData = themePreference == 0 ? lightmode : darkmode;
    }
    notifyListeners();
  }

  void _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? localeCode = prefs.getString(_localePreferenceKey);
    if (localeCode != null) {
      _locale = Locale(localeCode);
    }
    notifyListeners();
  }

  void _saveThemePreference(int themePreference) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(_themePreferenceKey, themePreference);
  }

  void _saveLocalePreference(String localeCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_localePreferenceKey, localeCode);
  }

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    _saveThemePreference(_themeData == lightmode ? 0 : 1);
    notifyListeners();
  }

  void setLocale(Locale newLocale) {
    _locale = newLocale;
    _saveLocalePreference(newLocale.languageCode);
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightmode) {
      _themeData = darkmode;
    } else {
      _themeData = lightmode;
    }
    _saveThemePreference(_themeData == lightmode ? 0 : 1);
    notifyListeners();
  }

  void toggleLanguage() {
    if (_locale.languageCode == 'en') {
      setLocale(const Locale('vi'));
    } else {
      setLocale(const Locale('en'));
    }
  }
}
