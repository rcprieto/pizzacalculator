import { HttpClient } from '@angular/common/http';
import { inject, Injectable, signal } from '@angular/core';
import { take } from 'rxjs';
import { ToastrService } from 'ngx-toastr';
import { ReceitaDto, ReceitaItemDto } from '../_models/dtos';
import { PaginatedResult, setPaginationHeader } from '../../_helpers/pagination';
import { environment } from '../../_environment/environment';

@Injectable({ providedIn: 'root' })
export class ReceitaService {
  private http = inject(HttpClient);
  private toastr = inject(ToastrService);
  private baseUrl = `${environment.apiUrl}/receita`;

  receitas = signal<ReceitaDto[]>([]);
  paginatedResult = signal<PaginatedResult<ReceitaDto[]>>({});
  receitaAtual = signal<ReceitaDto | null>(null);

  retornaReceitas(pageNumber: number, pageSize: number, search = '', orderBy = 'Nome', order = 'asc') {
    const params = setPaginationHeader(pageNumber, pageSize, search, orderBy, order);
    return this.http.get<ReceitaDto[]>(this.baseUrl, { observe: 'response', params })
      .pipe(take(1))
      .subscribe({
        next: response => {
          this.receitas.set(response.body as ReceitaDto[]);
          this.paginatedResult.set({
            result: this.receitas(),
            pagination: JSON.parse(response.headers.get('Pagination')!)
          });
        }
      });
  }

  retornaReceitaComItens(id: number) {
    return this.http.get<ReceitaDto>(`${this.baseUrl}/${id}`)
      .pipe(take(1))
      .subscribe({ next: receita => this.receitaAtual.set(receita) });
  }

  cadastrar(model: ReceitaDto) {
    return this.http.post<ReceitaDto>(this.baseUrl, model)
      .pipe(take(1))
      .subscribe({
        next: item => {
          this.receitas.update(l => [item, ...l]);
          this.receitaAtual.set({ ...item, itens: [] });
          this.toastr.success('Receita cadastrada com sucesso');
        },
        error: err => this.toastr.error(err?.error || 'Erro ao cadastrar')
      });
  }

  atualizar(model: ReceitaDto) {
    return this.http.put<ReceitaDto>(this.baseUrl, model)
      .pipe(take(1))
      .subscribe({
        next: item => {
          this.receitas.update(l => l.map(m => m.id === item.id ? item : m));
          this.toastr.success('Receita atualizada com sucesso');
        },
        error: err => this.toastr.error(err?.error || 'Erro ao atualizar')
      });
  }

  excluir(id: number) {
    return this.http.delete(`${this.baseUrl}/${id}`)
      .pipe(take(1))
      .subscribe({
        next: () => {
          this.receitas.update(l => l.filter(m => m.id !== id));
          this.toastr.success('Receita removida');
        },
        error: err => this.toastr.error(err?.error || 'Erro ao excluir')
      });
  }

  adicionarItem(receitaId: number, item: ReceitaItemDto) {
    return this.http.post<ReceitaItemDto>(`${this.baseUrl}/${receitaId}/item`, item)
      .pipe(take(1))
      .subscribe({
        next: resposta => {
          const itemComNome = { ...item, id: resposta.id };
          const atual = this.receitaAtual();
          if (atual) this.receitaAtual.set({ ...atual, itens: [...atual.itens, itemComNome] });
          this.toastr.success('Item adicionado');
        },
        error: err => this.toastr.error(err?.error || 'Erro ao adicionar item')
      });
  }

  atualizarItem(item: ReceitaItemDto) {
    return this.http.put<ReceitaItemDto>(`${this.baseUrl}/item`, item)
      .pipe(take(1))
      .subscribe({
        next: atualizado => {
          const atual = this.receitaAtual();
          if (atual) this.receitaAtual.set({ ...atual, itens: atual.itens.map(i => i.id === atualizado.id ? atualizado : i) });
          this.toastr.success('Item atualizado');
        },
        error: err => this.toastr.error(err?.error || 'Erro ao atualizar item')
      });
  }

  excluirItem(id: number) {
    return this.http.delete(`${this.baseUrl}/item/${id}`)
      .pipe(take(1))
      .subscribe({
        next: () => {
          const atual = this.receitaAtual();
          if (atual) this.receitaAtual.set({ ...atual, itens: atual.itens.filter(i => i.id !== id) });
          this.toastr.success('Item removido');
        },
        error: err => this.toastr.error(err?.error || 'Erro ao remover item')
      });
  }
}
