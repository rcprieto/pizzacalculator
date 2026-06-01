class UserDto {
  final String email;
  final String token;
  final String role;

  UserDto({required this.email, required this.token, this.role = ''});

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
    email: json['email'] ?? '',
    token: json['token'] ?? '',
    role: json['role'] ?? '',
  );
}

class LoginDto {
  final String email;
  final String password;

  LoginDto({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterDto {
  final String email;

  RegisterDto({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class EsqueciSenhaDto {
  final String email;

  EsqueciSenhaDto({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class UsuarioDto {
  final String id;
  final String email;
  final String role;
  final bool status;

  UsuarioDto({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
  });

  factory UsuarioDto.fromJson(Map<String, dynamic> json) => UsuarioDto(
    id: json['id'] ?? '',
    email: json['email'] ?? '',
    role: json['role'] ?? '',
    status: json['status'] ?? true,
  );
}

class IngredienteDto {
  int id;
  String nome;
  String marca;
  double preco;
  bool status;
  String? userId;

  IngredienteDto({
    this.id = 0,
    this.nome = '',
    this.marca = '',
    this.preco = 0,
    this.status = true,
    this.userId,
  });

  factory IngredienteDto.fromJson(Map<String, dynamic> json) => IngredienteDto(
    id: json['id'] ?? 0,
    nome: json['nome'] ?? '',
    marca: json['marca'] ?? '',
    preco: (json['preco'] ?? 0).toDouble(),
    status: json['status'] ?? true,
    userId: json['userId'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'marca': marca,
    'preco': preco,
    'status': status,
    if (userId != null) 'userId': userId,
  };
}

class IngredienteGrupoDto {
  int id;
  String nome;
  int ordem;
  bool status;
  String? userId;

  IngredienteGrupoDto({
    this.id = 0,
    this.nome = '',
    this.ordem = 0,
    this.status = true,
    this.userId,
  });

  factory IngredienteGrupoDto.fromJson(Map<String, dynamic> json) =>
      IngredienteGrupoDto(
        id: json['id'] ?? 0,
        nome: json['nome'] ?? '',
        ordem: json['ordem'] ?? 0,
        status: json['status'] ?? true,
        userId: json['userId'],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'ordem': ordem,
    'status': status,
    if (userId != null) 'userId': userId,
  };
}

class ReceitaItemDto {
  int id;
  int receitaId;
  int ingredienteId;
  String ingredienteNome;
  String ingredienteMarca;
  double pesoG;
  double percentual;
  String observacao;
  double ingredientePreco;
  int? ingredienteGrupoId;
  String ingredienteGrupoNome;
  int ingredienteGrupoOrdem;

  ReceitaItemDto({
    this.id = 0,
    this.receitaId = 0,
    this.ingredienteId = 0,
    this.ingredienteNome = '',
    this.ingredienteMarca = '',
    this.pesoG = 0,
    this.percentual = 0,
    this.observacao = '',
    this.ingredientePreco = 0,
    this.ingredienteGrupoId,
    this.ingredienteGrupoNome = '',
    this.ingredienteGrupoOrdem = 0,
  });

  factory ReceitaItemDto.fromJson(Map<String, dynamic> json) => ReceitaItemDto(
    id: json['id'] ?? 0,
    receitaId: json['receitaId'] ?? 0,
    ingredienteId: json['ingredienteId'] ?? 0,
    ingredienteNome: json['ingredienteNome'] ?? '',
    ingredienteMarca: json['ingredienteMarca'] ?? '',
    pesoG: (json['pesoG'] ?? 0).toDouble(),
    percentual: (json['percentual'] ?? 0).toDouble(),
    observacao: json['observacao'] ?? '',
    ingredientePreco: (json['ingredientePreco'] ?? 0).toDouble(),
    ingredienteGrupoId: json['ingredienteGrupoId'],
    ingredienteGrupoNome: json['ingredienteGrupoNome'] ?? '',
    ingredienteGrupoOrdem: json['ingredienteGrupoOrdem'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'receitaId': receitaId,
    'ingredienteId': ingredienteId,
    'pesoG': pesoG,
    'percentual': percentual,
    'observacao': observacao,
    if (ingredienteGrupoId != null) 'ingredienteGrupoId': ingredienteGrupoId,
  };
}

class ReceitaDto {
  int id;
  String nome;
  String modoPreparo;
  bool status;
  List<ReceitaItemDto> itens;

  ReceitaDto({
    this.id = 0,
    this.nome = '',
    this.modoPreparo = '',
    this.status = true,
    this.itens = const [],
  });

  factory ReceitaDto.fromJson(Map<String, dynamic> json) => ReceitaDto(
    id: json['id'] ?? 0,
    nome: json['nome'] ?? '',
    modoPreparo: json['modoPreparo'] ?? '',
    status: json['status'] ?? true,
    itens:
        (json['itens'] as List<dynamic>? ?? [])
            .map((e) => ReceitaItemDto.fromJson(e))
            .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'modoPreparo': modoPreparo,
    'status': status,
  };
}

class Pagination {
  final int currentPage;
  final int itemsPerPage;
  final int totalItems;
  final int totalPages;

  Pagination({
    required this.currentPage,
    required this.itemsPerPage,
    required this.totalItems,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json['currentPage'] ?? 1,
    itemsPerPage: json['itemsPerPage'] ?? 10,
    totalItems: json['totalItems'] ?? 0,
    totalPages: json['totalPages'] ?? 1,
  );
}

class PaginatedResult<T> {
  final List<T> result;
  final Pagination? pagination;

  PaginatedResult({required this.result, this.pagination});
}
