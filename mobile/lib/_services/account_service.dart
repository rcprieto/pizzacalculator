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
  bool get isAdmin => _usuarioAtual?.role == 'Admin';

  Future<void> inicializar() async {
    final token = await obterToken();
    final email = await obterEmail();
    final role = await obterRole();
    if (token != null && email != null) {
      _usuarioAtual = UserDto(email: email, token: token, role: role ?? '');
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
        await salvarToken(user.token, user.email, user.role);
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

  Future<List<UsuarioDto>?> listarUsuarios() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}account/usuarios'),
        headers: buildHeaders(_usuarioAtual?.token),
      );
      if (response.statusCode == 200) {
        final lista = json.decode(response.body) as List<dynamic>;
        return lista.map((e) => UsuarioDto.fromJson(e)).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> registrar(RegisterDto model) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}account/registrar'),
        headers: buildHeaders(_usuarioAtual?.token),
        body: json.encode(model.toJson()),
      );
      if (response.statusCode == 200) return null;
      final body = json.decode(response.body);
      return body?.toString() ?? 'Erro ao cadastrar usuário';
    } catch (e) {
      return 'Erro de conexão';
    }
  }

  Future<String?> esqueciSenha(EsqueciSenhaDto model) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}account/esqueci-senha'),
        headers: buildHeaders(null),
        body: json.encode(model.toJson()),
      );
      if (response.statusCode == 200) return null;
      return 'Erro ao processar solicitação';
    } catch (e) {
      return 'Erro de conexão';
    }
  }

  Future<String?> excluirUsuario(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${baseUrl}account/$id'),
        headers: buildHeaders(_usuarioAtual?.token),
      );
      if (response.statusCode == 204) return null;
      return 'Erro ao desativar usuário';
    } catch (e) {
      return 'Erro de conexão';
    }
  }
}
