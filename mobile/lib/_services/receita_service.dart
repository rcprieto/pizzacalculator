import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../_helpers/api_helper.dart';
import '../_models/dtos.dart';

class ReceitaService extends ChangeNotifier {
  List<ReceitaDto> receitas = [];
  ReceitaDto? receitaAtual;
  PaginatedResult<ReceitaDto>? paginatedResult;
  bool carregando = false;
  bool carregandoDetalhe = false;

  Future<void> retornaReceitas({
    int pageNumber = 1,
    int pageSize = 10,
    String search = '',
    String? token,
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
        Uri.parse('${baseUrl}receita?$query'),
        headers: buildHeaders(token),
      );
      if (response.statusCode == 200) {
        paginatedResult = parsePaginatedResponse(
          response,
          ReceitaDto.fromJson,
        );
        receitas = List.from(paginatedResult!.result);
      }
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<void> retornaDetalhe(int id, {String? token}) async {
    carregandoDetalhe = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}receita/$id'),
        headers: buildHeaders(token),
      );
      if (response.statusCode == 200) {
        receitaAtual = ReceitaDto.fromJson(json.decode(response.body));
      }
    } finally {
      carregandoDetalhe = false;
      notifyListeners();
    }
  }

  Future<String?> cadastrar(ReceitaDto model, String token) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}receita'),
        headers: buildHeaders(token),
        body: json.encode(model.toJson()),
      );
      if (response.statusCode == 200) {
        final nova = ReceitaDto.fromJson(json.decode(response.body));
        receitas.insert(0, nova);
        notifyListeners();
        return null;
      }
      return 'Erro ao cadastrar receita';
    } catch (e) {
      return 'Erro de conexão';
    }
  }

  Future<String?> atualizar(ReceitaDto model, String token) async {
    try {
      final response = await http.put(
        Uri.parse('${baseUrl}receita'),
        headers: buildHeaders(token),
        body: json.encode(model.toJson()),
      );
      if (response.statusCode == 200) {
        final atualizada = ReceitaDto.fromJson(json.decode(response.body));
        final index = receitas.indexWhere((r) => r.id == atualizada.id);
        if (index != -1) receitas[index] = atualizada;
        notifyListeners();
        return null;
      }
      return 'Erro ao atualizar receita';
    } catch (e) {
      return 'Erro de conexão';
    }
  }

  Future<String?> excluir(int id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${baseUrl}receita/$id'),
        headers: buildHeaders(token),
      );
      if (response.statusCode == 204) {
        receitas.removeWhere((r) => r.id == id);
        notifyListeners();
        return null;
      }
      return 'Erro ao excluir receita';
    } catch (e) {
      return 'Erro de conexão';
    }
  }

  Future<String?> adicionarItem(ReceitaItemDto item, String token) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}receita/${item.receitaId}/item'),
        headers: buildHeaders(token),
        body: json.encode(item.toJson()),
      );
      if (response.statusCode == 200) {
        final novoItem = ReceitaItemDto.fromJson(json.decode(response.body));
        receitaAtual?.itens.add(novoItem);
        notifyListeners();
        return null;
      }
      return 'Erro ao adicionar item';
    } catch (e) {
      return 'Erro de conexão';
    }
  }

  Future<String?> atualizarItem(ReceitaItemDto item, String token) async {
    try {
      final response = await http.put(
        Uri.parse('${baseUrl}receita/item'),
        headers: buildHeaders(token),
        body: json.encode(item.toJson()),
      );
      if (response.statusCode == 200) {
        final atualizado = ReceitaItemDto.fromJson(json.decode(response.body));
        final index = receitaAtual?.itens.indexWhere(
          (i) => i.id == atualizado.id,
        );
        if (index != null && index != -1) {
          receitaAtual!.itens[index] = atualizado;
        }
        notifyListeners();
        return null;
      }
      return 'Erro ao atualizar item';
    } catch (e) {
      return 'Erro de conexão';
    }
  }

  Future<String?> excluirItem(int id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${baseUrl}receita/item/$id'),
        headers: buildHeaders(token),
      );
      if (response.statusCode == 204) {
        receitaAtual?.itens.removeWhere((i) => i.id == id);
        notifyListeners();
        return null;
      }
      return 'Erro ao excluir item';
    } catch (e) {
      return 'Erro de conexão';
    }
  }
}
