import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { DecimalPipe } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { RouterLink } from '@angular/router';

type ModoBiga = 'farinha' | 'biga';

@Component({
  selector: 'app-biga-calculator',
  templateUrl: './biga-calculator.html',
  styleUrls: ['../pizza-calculator/pizza-calculator.css', './biga-calculator.css'],
  imports: [ReactiveFormsModule, DecimalPipe, RouterLink],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BigaCalculatorComponent {
  private fb = inject(FormBuilder);

  // A biga leva 50% da farinha total, com água igual a 50% da farinha da biga
  private readonly percentualFarinhaBiga = 0.5;
  private readonly hidratacaoBiga = 0.5;
  private readonly percentualSal = 0.02;

  modo = signal<ModoBiga>('farinha');

  registerForm = this.fb.group({
    quantidade: [null as number | null, [Validators.required, Validators.min(1)]],
    hidratacao: [60],
  });

  farinhaTotal = signal<number>(0);
  aguaTotal = signal<number>(0);
  bigaFarinha = signal<number>(0);
  bigaAgua = signal<number>(0);
  bigaPeso = signal<number>(0);
  massaFarinha = signal<number>(0);
  massaAgua = signal<number>(0);
  sal = signal<number>(0);
  massaTotal = signal<number>(0);
  hidratacaoCalculada = signal<number>(0);

  calculado = signal<boolean>(false);

  selecionarModo(modo: ModoBiga): void {
    if (this.modo() === modo) return;
    this.modo.set(modo);
    this.registerForm.controls.quantidade.reset();
    this.calculado.set(false);
  }

  calcular(): void {
    if (this.registerForm.invalid) {
      this.calculado.set(false);
      return;
    }

    const quantidade = this.registerForm.controls.quantidade.value!;
    const hidratacaoPercentual = this.registerForm.controls.hidratacao.value!;
    const hidratacao = hidratacaoPercentual / 100;

    let bigaFarinha: number;
    let bigaAgua: number;

    if (this.modo() === 'farinha') {
      // Informado: farinha total da receita
      bigaFarinha = quantidade * this.percentualFarinhaBiga;
      bigaAgua = bigaFarinha * this.hidratacaoBiga;
    } else {
      // Informado: peso da biga pronta (farinha + 50% de água => peso / 1,5)
      bigaFarinha = quantidade / (1 + this.hidratacaoBiga);
      bigaAgua = quantidade - bigaFarinha;
    }

    const farinhaTotal = bigaFarinha / this.percentualFarinhaBiga;
    const aguaTotal = farinhaTotal * hidratacao;
    const sal = farinhaTotal * this.percentualSal;

    this.farinhaTotal.set(farinhaTotal);
    this.aguaTotal.set(aguaTotal);
    this.bigaFarinha.set(bigaFarinha);
    this.bigaAgua.set(bigaAgua);
    this.bigaPeso.set(bigaFarinha + bigaAgua);
    this.massaFarinha.set(farinhaTotal - bigaFarinha);
    this.massaAgua.set(aguaTotal - bigaAgua);
    this.sal.set(sal);
    this.massaTotal.set(farinhaTotal + aguaTotal + sal);
    this.hidratacaoCalculada.set(hidratacaoPercentual);

    this.calculado.set(true);
  }
}
