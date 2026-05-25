import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../_helpers/api_helper.dart';
import '../_models/dtos.dart';

class IngredienteGrupoService extends ChangeNotifier {
  List<IngredienteGrupoDto> grupos = [];
  List<IngredienteGrupoDto> todos = [];
  PaginatedResult<IngredienteGrupoDto>? paginatedResult;
  bool carregando = false;

  Future<void> retornaGrupos(
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
        orderBy: 'ordem',
        order: 'asc',
      );
      final response = await http.get(
        Uri.parse('${baseUrl}ingredientegrupo?$query'),
        headers: buildHeaders(token),
      );
      if (response.statusCode == 200) {
        paginatedResult = parsePaginatedResponse(
          response,
          IngredienteGrupoDto.fromJson,
        );
        grupos = List.from(paginatedResult!.result);
      }
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<void> retornaTodos(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}ingredientegrupo/todos'),
        headers: buildHeaders(token),
      );
      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        todos = body.map((e) => IngredienteGrupoDto.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<String?> cadastrar(IngredienteGrupoDto model, String token) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}ingredientegrupo'),
        headers: buildHeaders(token),
        body: json.encode(model.toJson()),
      );
      if (response.statusCode == 200) {
        final novo = IngredienteGrupoDto.fromJson(json.decode(response.body));
        grupos.insert(0, novo);
        notifyListeners();
        return null;
      }
      return 'Erro ao cadastrar grupo';
    } catch (e) {
      return 'Erro de conexão';
    }
  }

  Future<String?> atualizar(IngredienteGrupoDto model, String token) async {
    try {
      final response = await http.put(
        Uri.parse('${baseUrl}ingredientegrupo'),
        headers: buildHeaders(token),
        body: json.encode(model.toJson()),
      );
      if (response.statusCode == 200) {
        final atualizado = IngredienteGrupoDto.fromJson(
          json.decode(response.body),
        );
        final index = grupos.indexWhere((g) => g.id == atualizado.id);
        if (index != -1) grupos[index] = atualizado;
        notifyListeners();
        return null;
      }
      return 'Erro ao atualizar grupo';
    } catch (e) {
      return 'Erro de conexão';
    }
  }

  Future<String?> excluir(int id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${baseUrl}ingredientegrupo/$id'),
        headers: buildHeaders(token),
      );
      if (response.statusCode == 204) {
        grupos.removeWhere((g) => g.id == id);
        notifyListeners();
        return null;
      }
      return 'Erro ao excluir grupo';
    } catch (e) {
      return 'Erro de conexão';
    }
  }
}
