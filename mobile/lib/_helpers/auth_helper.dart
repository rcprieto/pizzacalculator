import 'package:shared_preferences/shared_preferences.dart';

const _keyToken = 'jwt_token';
const _keyEmail = 'user_email';

Future<void> salvarToken(String token, String email) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_keyToken, token);
  await prefs.setString(_keyEmail, email);
}

Future<String?> obterToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_keyToken);
}

Future<String?> obterEmail() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_keyEmail);
}

Future<void> limparToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_keyToken);
  await prefs.remove(_keyEmail);
}
