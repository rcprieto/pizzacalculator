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

  erro = '';
  carregando = false;

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

  get f() { return this.form.controls; }
}
