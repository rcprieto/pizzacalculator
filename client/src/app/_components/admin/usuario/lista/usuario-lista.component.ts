import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AccountService } from '../../../../_services/account.service';
import { UsuarioDto } from '../../../../_models/dtos';

@Component({
  selector: 'app-usuario-lista',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './usuario-lista.component.html',
})
export class UsuarioListaComponent implements OnInit {
  private accountService = inject(AccountService);

  usuarios: UsuarioDto[] = [];
  carregando = false;
  novoEmail = '';
  salvando = false;
  mostrarFormulario = false;
  erro = '';

  get currentUserId() { return this.accountService.currentUser()?.email; }

  ngOnInit() {
    this.carregar();
  }

  carregar() {
    this.carregando = true;
    this.accountService.listarUsuarios().subscribe({
      next: lista => { this.usuarios = lista; this.carregando = false; },
      error: () => { this.carregando = false; }
    });
  }

  salvar() {
    if (!this.novoEmail) return;
    this.salvando = true;
    this.erro = '';
    this.accountService.registrar({ email: this.novoEmail }).subscribe({
      next: usuario => {
        this.usuarios = [...this.usuarios, usuario];
        this.novoEmail = '';
        this.mostrarFormulario = false;
        this.salvando = false;
      },
      error: err => {
        this.erro = err?.error || 'Erro ao cadastrar usuário';
        this.salvando = false;
      }
    });
  }

  confirmarExclusao(usuario: UsuarioDto) {
    if (usuario.email === this.currentUserId) return;
    if (!confirm(`Desativar "${usuario.email}"?`)) return;
    this.accountService.excluirUsuario(usuario.id).subscribe({
      next: () => { this.usuarios = this.usuarios.filter(u => u.id !== usuario.id); }
    });
  }
}
