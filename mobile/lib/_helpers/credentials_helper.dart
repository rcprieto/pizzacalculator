import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage();
const _keyEmail = 'saved_email';
const _keySenha = 'saved_senha';

Future<void> salvarCredenciais(String email, String senha) async {
  await _storage.write(key: _keyEmail, value: email);
  await _storage.write(key: _keySenha, value: senha);
}

Future<({String email, String senha})?> carregarCredenciais() async {
  final email = await _storage.read(key: _keyEmail);
  final senha = await _storage.read(key: _keySenha);
  if (email != null && senha != null) return (email: email, senha: senha);
  return null;
}

Future<void> limparCredenciais() async {
  await _storage.delete(key: _keyEmail);
  await _storage.delete(key: _keySenha);
}
