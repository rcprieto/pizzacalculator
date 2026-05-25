import { HttpClient } from '@angular/common/http';
import { computed, inject, Injectable, signal } from '@angular/core';
import { map, take } from 'rxjs';
import { LoginDto, RegisterDto, UserDto, UsuarioDto } from '../_models/dtos';
import { environment } from '../../_environment/environment';

@Injectable({ providedIn: 'root' })
export class AccountService {
  private http = inject(HttpClient);
  private baseUrl = environment.apiUrl;

  currentUser = signal<UserDto | null>(this.carregarUsuario());
  isAdmin = computed(() => this.currentUser()?.role === 'Admin');

  private carregarUsuario(): UserDto | null {
    const stored = localStorage.getItem('user');
    return stored ? JSON.parse(stored) : null;
  }

  login(model: LoginDto) {
    return this.http.post<UserDto>(`${this.baseUrl}/account/login`, model).pipe(
      take(1),
      map(user => {
        localStorage.setItem('user', JSON.stringify(user));
        this.currentUser.set(user);
        return user;
      })
    );
  }

  logout() {
    localStorage.removeItem('user');
    this.currentUser.set(null);
  }

  listarUsuarios() {
    return this.http.get<UsuarioDto[]>(`${this.baseUrl}/account/usuarios`).pipe(take(1));
  }

  registrar(model: RegisterDto) {
    return this.http.post<UsuarioDto>(`${this.baseUrl}/account/registrar`, model).pipe(take(1));
  }

  excluirUsuario(id: string) {
    return this.http.delete(`${this.baseUrl}/account/${id}`).pipe(take(1));
  }
}
