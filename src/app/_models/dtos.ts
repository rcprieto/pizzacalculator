export interface UserDto {
  email: string;
  token: string;
  password?: string;
}

export interface LoginDto {
  email: string;
  password: string;
}

export interface IngredienteDto {
  id: number;
  nome: string;
  marca: string;
  preco: number;
  status: boolean;
}

export interface ReceitaDto {
  id: number;
  nome: string;
  modoPreparo: string;
  status: boolean;
  itens: ReceitaItemDto[];
}

export interface IngredienteGrupoDto {
  id: number;
  nome: string;
  ordem: number;
  status: boolean;
}

export interface ReceitaItemDto {
  id: number;
  receitaId: number;
  ingredienteId: number;
  ingredienteNome: string;
  ingredienteMarca: string;
  pesoG: number;
  percentual: number;
  observacao: string;
  ingredientePreco: number;
  ingredienteGrupoId: number | null;
  ingredienteGrupoNome: string;
  ingredienteGrupoOrdem: number;
}
