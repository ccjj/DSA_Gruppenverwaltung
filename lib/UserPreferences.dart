import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  Future<void> saveUserEmail(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', email);
  }

  Future<String?> getUserEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

  Future<void> saveUserPassword(String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPassword', password);
  }

  Future<String?> getUserPassword() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userPassword');
  }

  Future<void> saveTheme(bool isLightTheme) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLightTheme', isLightTheme);
  }

  Future<bool?> getTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLightTheme');
  }
}
