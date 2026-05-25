import 'package:shared_preferences/shared_preferences.dart';

const _keyToken = 'jwt_token';
const _keyEmail = 'user_email';
const _keyRole = 'user_role';

Future<void> salvarToken(String token, String email, String role) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_keyToken, token);
  await prefs.setString(_keyEmail, email);
  await prefs.setString(_keyRole, role);
}

Future<String?> obterToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_keyToken);
}

Future<String?> obterEmail() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_keyEmail);
}

Future<String?> obterRole() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_keyRole);
}

Future<void> limparToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_keyToken);
  await prefs.remove(_keyEmail);
  await prefs.remove(_keyRole);
}
