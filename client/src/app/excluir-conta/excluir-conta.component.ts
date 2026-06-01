import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { take } from 'rxjs';
import { environment } from '../../_environment/environment';

@Component({
  selector: 'app-excluir-conta',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './excluir-conta.component.html',
})
export class ExcluirContaComponent {
  private fb = inject(FormBuilder);
  private http = inject(HttpClient);

  form = this.fb.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', Validators.required],
    confirmacao: ['', Validators.required],
  });

  etapa: 'formulario' | 'confirmando' | 'sucesso' | 'erro' = 'formulario';
  carregando = false;
  erro = '';

  get f() { return this.form.controls; }

  get confirmacaoInvalida() {
    return this.f['confirmacao'].value?.toUpperCase() !== 'EXCLUIR';
  }

  avancarConfirmacao() {
    if (this.form.controls['email'].invalid || this.form.controls['password'].invalid) {
      this.form.controls['email'].markAsTouched();
      this.form.controls['password'].markAsTouched();
      return;
    }
    this.etapa = 'confirmando';
  }

  confirmarExclusao() {
    if (this.confirmacaoInvalida) return;

    this.carregando = true;
    this.erro = '';

    const model = {
      email: this.f['email'].value,
      password: this.f['password'].value,
    };

    this.http.post(`${environment.apiUrl}/account/excluir-conta`, model)
      .pipe(take(1))
      .subscribe({
        next: () => {
          this.etapa = 'sucesso';
          this.carregando = false;
        },
        error: (err) => {
          this.erro = err?.error || 'Email ou senha inválidos. Verifique e tente novamente.';
          this.etapa = 'formulario';
          this.carregando = false;
        },
      });
  }

  voltar() {
    this.etapa = 'formulario';
    this.erro = '';
    this.f['confirmacao'].setValue('');
  }
}
