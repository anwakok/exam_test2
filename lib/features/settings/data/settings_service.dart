import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool get isDarkMode => _prefs.getBool('darkMode') ?? false;
  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool('darkMode', value);
  }

  String get language => _prefs.getString('language') ?? 'en';
  Future<void> setLanguage(String value) async {
    await _prefs.setString('language', value);
  }

  bool get soundEnabled => _prefs.getBool('sound') ?? true;
  Future<void> setSoundEnabled(bool value) async {
    await _prefs.setBool('sound', value);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}
