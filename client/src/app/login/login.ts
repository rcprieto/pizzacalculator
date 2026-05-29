import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AccountService } from '../_services/account.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterLink],
  templateUrl: './login.html',
})
export class LoginComponent {
  private fb = inject(FormBuilder);
  private accountService = inject(AccountService);
  private router = inject(Router);

  form = this.fb.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', Validators.required],
  });

  esqueciForm = this.fb.group({
    email: ['', [Validators.required, Validators.email]],
  });

  erro = '';
  carregando = false;
  mostraEsqueci = false;
  esqueciEnviado = false;
  esqueciCarregando = false;
  esqueciErro = '';

  entrar() {
    if (this.form.invalid) return;
    this.carregando = true;
    this.erro = '';
    this.accountService.login(this.form.value as any).subscribe({
      next: () => this.router.navigateByUrl('/admin/receitas'),
      error: () => {
        this.erro = 'Email ou senha inválidos.';
        this.carregando = false;
      },
    });
  }

  abrirEsqueci() {
    this.mostraEsqueci = true;
    this.esqueciEnviado = false;
    this.esqueciErro = '';
    this.esqueciForm.patchValue({ email: this.form.value.email ?? '' });
  }

  enviarEsqueci() {
    if (this.esqueciForm.invalid) return;
    this.esqueciCarregando = true;
    this.esqueciErro = '';
    this.accountService.esqueciSenha(this.esqueciForm.value as any).subscribe({
      next: () => {
        this.esqueciEnviado = true;
        this.esqueciCarregando = false;
      },
      error: () => {
        this.esqueciErro = 'Erro ao enviar. Verifique o e-mail e tente novamente.';
        this.esqueciCarregando = false;
      },
    });
  }

  get f() { return this.form.controls; }
  get fe() { return this.esqueciForm.controls; }
}
