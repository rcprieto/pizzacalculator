import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../_helpers/api_helper.dart';
import '../_helpers/auth_helper.dart';
import '../_models/dtos.dart';

class AccountService extends ChangeNotifier {
  UserDto? _usuarioAtual;
  bool _carregando = false;

  UserDto? get usuarioAtual => _usuarioAtual;
  bool get carregando => _carregando;
  bool get estaLogado => _usuarioAtual != null;

  Future<void> inicializar() async {
    final token = await obterToken();
    final email = await obterEmail();
    if (token != null && email != null) {
      _usuarioAtual = UserDto(email: email, token: token);
      notifyListeners();
    }
  }

  Future<String?> login(LoginDto model) async {
    _carregando = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}account/login'),
        headers: buildHeaders(null),
        body: json.encode(model.toJson()),
      );
      if (response.statusCode == 200) {
        final user = UserDto.fromJson(json.decode(response.body));
        await salvarToken(user.token, user.email);
        _usuarioAtual = user;
        return null;
      }
      return 'Usuário ou senha inválidos';
    } catch (e) {
      return 'Erro de conexão com o servidor';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await limparToken();
    _usuarioAtual = null;
    notifyListeners();
  }
}
