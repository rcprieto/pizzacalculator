import { HttpClient } from '@angular/common/http';
import { inject, Injectable, signal } from '@angular/core';
import { take } from 'rxjs';
import { ToastrService } from 'ngx-toastr';
import { IngredienteGrupoDto } from '../_models/dtos';
import { PaginatedResult, setPaginationHeader } from '../../_helpers/pagination';
import { environment } from '../../_environment/environment';

@Injectable({ providedIn: 'root' })
export class IngredienteGrupoService {
  private http = inject(HttpClient);
  private toastr = inject(ToastrService);
  private baseUrl = `${environment.apiUrl}/ingredientegrupo`;

  grupos = signal<IngredienteGrupoDto[]>([]);
  paginatedResult = signal<PaginatedResult<IngredienteGrupoDto[]>>({});
  todos = signal<IngredienteGrupoDto[]>([]);

  retornaGrupos(pageNumber: number, pageSize: number, search = '', orderBy = 'Nome', order = 'asc') {
    const params = setPaginationHeader(pageNumber, pageSize, search, orderBy, order);
    return this.http.get<IngredienteGrupoDto[]>(this.baseUrl, { observe: 'response', params })
      .pipe(take(1))
      .subscribe({
        next: response => {
          this.grupos.set(response.body as IngredienteGrupoDto[]);
          this.paginatedResult.set({
            result: this.grupos(),
            pagination: JSON.parse(response.headers.get('Pagination')!)
          });
        }
      });
  }

  retornaTodos() {
    return this.http.get<IngredienteGrupoDto[]>(`${this.baseUrl}/todos`)
      .pipe(take(1))
      .subscribe({ next: lista => this.todos.set(lista) });
  }

  cadastrar(model: IngredienteGrupoDto) {
    return this.http.post<IngredienteGrupoDto>(this.baseUrl, model)
      .pipe(take(1))
      .subscribe({
        next: item => {
          this.grupos.update(l => [item, ...l]);
          this.toastr.success('Grupo cadastrado com sucesso');
        },
        error: err => this.toastr.error(err?.error || 'Erro ao cadastrar')
      });
  }

  atualizar(model: IngredienteGrupoDto) {
    return this.http.put<IngredienteGrupoDto>(this.baseUrl, model)
      .pipe(take(1))
      .subscribe({
        next: item => {
          this.grupos.update(l => l.map(m => m.id === item.id ? item : m));
          this.toastr.success('Grupo atualizado com sucesso');
        },
        error: err => this.toastr.error(err?.error || 'Erro ao atualizar')
      });
  }

  excluir(id: number) {
    return this.http.delete(`${this.baseUrl}/${id}`)
      .pipe(take(1))
      .subscribe({
        next: () => {
          this.grupos.update(l => l.filter(m => m.id !== id));
          this.toastr.success('Grupo removido');
        },
        error: err => this.toastr.error(err?.error || 'Erro ao excluir')
      });
  }
}
