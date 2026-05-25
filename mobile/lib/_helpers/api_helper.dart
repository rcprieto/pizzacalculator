import 'dart:convert';
import 'package:http/http.dart' as http;
import '../_models/dtos.dart';

const String baseUrl = 'https://pizza.citapps.com.br/api/';

Map<String, String> buildHeaders(String? token) {
  final headers = <String, String>{'Content-Type': 'application/json'};
  if (token != null && token.isNotEmpty) {
    headers['Authorization'] = 'Bearer $token';
  }
  return headers;
}

PaginatedResult<T> parsePaginatedResponse<T>(
  http.Response response,
  T Function(Map<String, dynamic>) fromJson,
) {
  final List<dynamic> body = json.decode(response.body);
  final items = body.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  Pagination? pagination;
  final paginationHeader = response.headers['pagination'];
  if (paginationHeader != null) {
    pagination = Pagination.fromJson(json.decode(paginationHeader));
  }
  return PaginatedResult<T>(result: items, pagination: pagination);
}

String buildPaginationQuery({
  int pageNumber = 1,
  int pageSize = 10,
  String search = '',
  String orderBy = '',
  String order = '',
}) {
  final params = <String, String>{
    'pageNumber': pageNumber.toString(),
    'pageSize': pageSize.toString(),
  };
  if (search.isNotEmpty) params['search'] = search;
  if (orderBy.isNotEmpty) params['orderBy'] = orderBy;
  if (order.isNotEmpty) params['order'] = order;
  return Uri(queryParameters: params).query;
}
