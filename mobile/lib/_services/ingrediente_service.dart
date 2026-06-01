import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../_helpers/api_helper.dart';
import '../_models/dtos.dart';

class IngredienteService extends ChangeNotifier {
  List<IngredienteDto> ingredientes = [];
  List<IngredienteDto> todos = [];
  PaginatedResult<IngredienteDto>? paginatedResult;
  bool carregando = false;

  Future<void> retornaIngredientes(
    String token, {
    int pageNumber = 1,
    int pageSize = 10,
    String search = '',
  }) async {
    carregando = true;
    notifyListeners();
    try {
      final query = buildPaginationQuery(
        pageNumber: pageNumber,
        pageSize: pageSize,
        search: search,
        orderBy: 'nome',
        order: 'asc',
      );
      final response = await http.get(
        Uri.parse('${baseUrl}ingrediente?$query'),
        headers: buildHeaders(token),
      );
      if (response.statusCode == 200) {
        paginatedResult = parsePaginatedResponse(
          response,
          IngredienteDto.fromJson,
        );
        ingredientes = List.from(paginatedResult!.result);
      }
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<void> retornaTodos(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}ingrediente/todos'),
        headers: buildHeaders(token),
      );
      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        todos = body.map((e) => IngredienteDto.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<String?> cadastrar(IngredienteDto model, String token) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}ingrediente'),
        headers: buildHeaders(token),
        body: json.encode(model.toJson()),
      );
      if (response.statusCode == 200) {
        final novo = IngredienteDto.fromJson(json.decode(response.body));
        ingredientes.insert(0, novo);
        notifyListeners();
        return null;
      }
      return 'Erro ao cadastrar ingrediente';
    } catch (e) {
      return 'Erro de conexão';
    }
  }

  Future<String?> atualizar(IngredienteDto model, String token) async {
    try {
      final response = await http.put(
        Uri.parse('${baseUrl}ingrediente'),
        headers: buildHeaders(token),
        body: json.encode(model.toJson()),
      );
      if (response.statusCode == 200) {
        final atualizado = IngredienteDto.fromJson(json.decode(response.body));
        final index = ingredientes.indexWhere((i) => i.id == atualizado.id);
        if (index != -1) ingredientes[index] = atualizado;
        notifyListeners();
        return null;
      }
      if (response.statusCode == 403) return 'Sem permissão para editar este ingrediente';
      final body = response.body.replaceAll('"', '');
      return body.isNotEmpty ? body : 'Erro ao atualizar ingrediente (${response.statusCode})';
    } catch (e) {
      return 'Erro de conexão: $e';
    }
  }

  Future<String?> excluir(int id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${baseUrl}ingrediente/$id'),
        headers: buildHeaders(token),
      );
      if (response.statusCode == 204) {
        ingredientes.removeWhere((i) => i.id == id);
        notifyListeners();
        return null;
      }
      return 'Erro ao excluir ingrediente';
    } catch (e) {
      return 'Erro de conexão';
    }
  }
}
