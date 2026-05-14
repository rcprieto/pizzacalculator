import { HttpClient } from '@angular/common/http';
import { inject, Injectable, signal } from '@angular/core';
import { take } from 'rxjs';
import { ToastrService } from 'ngx-toastr';
import { IngredienteDto } from '../_models/dtos';
import { PaginatedResult, setPaginationHeader } from '../../_helpers/pagination';
import { environment } from '../../_environment/environment';

@Injectable({ providedIn: 'root' })
export class IngredienteService {
  private http = inject(HttpClient);
  private toastr = inject(ToastrService);
  private baseUrl = `${environment.apiUrl}/ingrediente`;

  ingredientes = signal<IngredienteDto[]>([]);
  paginatedResult = signal<PaginatedResult<IngredienteDto[]>>({});
  todos = signal<IngredienteDto[]>([]);

  retornaIngredientes(pageNumber: number, pageSize: number, search = '', orderBy = 'Nome', order = 'asc') {
    const params = setPaginationHeader(pageNumber, pageSize, search, orderBy, order);
    return this.http.get<IngredienteDto[]>(this.baseUrl, { observe: 'response', params })
      .pipe(take(1))
      .subscribe({
        next: response => {
          this.ingredientes.set(response.body as IngredienteDto[]);
          this.paginatedResult.set({
            result: this.ingredientes(),
            pagination: JSON.parse(response.headers.get('Pagination')!)
          });
        }
      });
  }

  retornaTodos() {
    return this.http.get<IngredienteDto[]>(`${this.baseUrl}/todos`)
      .pipe(take(1))
      .subscribe({ next: lista => this.todos.set(lista) });
  }

  cadastrar(model: IngredienteDto) {
    return this.http.post<IngredienteDto>(this.baseUrl, model)
      .pipe(take(1))
      .subscribe({
        next: item => {
          this.ingredientes.update(l => [item, ...l]);
          this.toastr.success('Ingrediente cadastrado com sucesso');
        },
        error: err => this.toastr.error(err?.error || 'Erro ao cadastrar')
      });
  }

  atualizar(model: IngredienteDto) {
    return this.http.put<IngredienteDto>(this.baseUrl, model)
      .pipe(take(1))
      .subscribe({
        next: item => {
          this.ingredientes.update(l => l.map(m => m.id === item.id ? item : m));
          this.toastr.success('Ingrediente atualizado com sucesso');
        },
        error: err => this.toastr.error(err?.error || 'Erro ao atualizar')
      });
  }

  excluir(id: number) {
    return this.http.delete(`${this.baseUrl}/${id}`)
      .pipe(take(1))
      .subscribe({
        next: () => {
          this.ingredientes.update(l => l.filter(m => m.id !== id));
          this.toastr.success('Ingrediente removido');
        },
        error: err => this.toastr.error(err?.error || 'Erro ao excluir')
      });
  }
}
