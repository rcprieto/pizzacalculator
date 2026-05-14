import { CommonModule, DecimalPipe } from '@angular/common';
import { ChangeDetectionStrategy, Component, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-pao',
  imports: [CommonModule, FormsModule, DecimalPipe],
  templateUrl: './pao.html',
  styleUrl: './pao.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PaoComponent {
  numberOfBread = signal<number | null>(null);
  hydrationPercentage = signal<number>(65);

  totalFlour = signal<number | null>(null);
  totalWater = signal<number | null>(null);
  salt = signal<number | null>(null);
  yeast = signal<number | null>(null);
  bigaFlour = signal<number | null>(null);
  bigaWater = signal<number | null>(null);
  doughFlour = signal<number | null>(null);
  doughWater = signal<number | null>(null);
  totalMassa = signal<number | null>(null);
  totalPizzas = signal<number | null>(null);
  totalPessoas = signal<number | null>(null);
  tipo = signal<string>('I');
  fermento = signal<string>('N');
  tipoNome = signal<string>('');

  calculated = signal<boolean>(false);

  calculatePizza(): void {
    if (this.numberOfBread() === null || this.hydrationPercentage() === null) {
      this.calculated.set(false);
      return;
    }

    this.tipoNome.set(this.tipo() == 'I' ? 'Italiano' : this.tipo() == 'F' ? 'Forma' : '');

    let pizzaPorPessoa = 1;
    let massaPorPizza = 250;

    if (this.tipo() == 'PE30') pizzaPorPessoa = 0.8;
    else if (this.tipo() == 'PE40') pizzaPorPessoa = 0.5;

    if (this.tipo() == 'P40' || this.tipo() == 'PE40') massaPorPizza = 300;

    const numberOfPizzas = this.numberOfPeople()! * pizzaPorPessoa;

    //Total da Massa
    const totalDoughWeight = parseInt(numberOfPizzas.toFixed(0)) * massaPorPizza;

    const hydrationDecimal = this.hydrationPercentage()! / 100;

    const totalFlour = totalDoughWeight / (1 + hydrationDecimal);
    const totalWater = totalDoughWeight - totalFlour;
    const salt = totalFlour * 0.02; // Assumindo 2% sal
    const yeast = totalFlour / 500; // Assumindo 0.2% fermento

    const bigaFlour = totalFlour / 2;
    const bigaWater = bigaFlour * 0.5;

    const doughFlour = totalFlour - bigaFlour;
    const doughWater = totalWater - bigaWater;

    if (this.tipo() == 'P40') pizzaPorPessoa = 0.5;
    else if (this.tipo() == 'P30') pizzaPorPessoa = 0.8;

    if (this.tipo() == 'PE30' || this.tipo() == 'PE40') this.totalPessoas.set(this.numberOfPeople());
    else {
      const totalP = numberOfPizzas / pizzaPorPessoa;

      this.totalPessoas.set(parseFloat(totalP.toFixed(0)));
    }

    this.totalPizzas.set(parseFloat(numberOfPizzas.toFixed(0)));
    this.totalFlour.set(parseFloat(totalFlour.toFixed(1)));
    this.totalWater.set(parseFloat(totalWater.toFixed(1)));
    this.totalMassa.set(totalDoughWeight);
    this.salt.set(parseFloat(salt.toFixed(1)));
    this.yeast.set(parseFloat(yeast.toFixed(1)));
    this.bigaFlour.set(parseFloat(bigaFlour.toFixed(1)));
    this.bigaWater.set(parseFloat(bigaWater.toFixed(1)));
    this.doughFlour.set(parseFloat(doughFlour.toFixed(1)));
    this.doughWater.set(parseFloat(doughWater.toFixed(1)));
    this.numberOfPizzasTotal.set(parseFloat(numberOfPizzas.toFixed(1)));

    this.calculated.set(true);
    return;
  }
}
