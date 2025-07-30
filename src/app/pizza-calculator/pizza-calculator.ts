import { ChangeDetectionStrategy, Component, signal } from '@angular/core';
import { CommonModule, DecimalPipe } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-pizza-calculator',
  templateUrl: './pizza-calculator.html',
  styleUrl: './pizza-calculator.css',
  imports: [CommonModule, FormsModule, DecimalPipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PizzaCalculatorComponent {
  numberOfPeople = signal<number | null>(null);
  hydrationPercentage = signal<number>(65);

  totalFlour = signal<number | null>(null);
  totalWater = signal<number | null>(null);
  salt = signal<number | null>(null);
  yeast = signal<number | null>(null);
  bigaFlour = signal<number | null>(null);
  bigaWater = signal<number | null>(null);
  doughFlour = signal<number | null>(null);
  doughWater = signal<number | null>(null);
  numberOfPizzasTotal = signal<number | null>(null);

  calculated = signal<boolean>(false);

  calculatePizza(): void {
    if (this.numberOfPeople() === null || this.hydrationPercentage() === null) {
      this.calculated.set(false);
      return;
    }

    const numberOfPizzas = this.numberOfPeople()! * 0.8;
    const totalDoughWeight = numberOfPizzas * 250;
    const hydrationDecimal = this.hydrationPercentage()! / 100;

    const totalFlour = totalDoughWeight / (1 + hydrationDecimal);
    const totalWater = totalDoughWeight - totalFlour;
    const salt = totalFlour * 0.02; // Assuming 2% salt
    const yeast = totalFlour / 500; // Assuming 0.2% yeast

    const bigaFlour = totalFlour / 2;
    const bigaWater = bigaFlour * 0.5;

    const doughFlour = totalFlour - bigaFlour;
    const doughWater = totalWater - bigaWater;

    this.totalFlour.set(parseFloat(totalFlour.toFixed(0)));
    this.totalWater.set(parseFloat(totalWater.toFixed(0)));
    this.salt.set(parseFloat(salt.toFixed(0)));
    this.yeast.set(parseFloat(yeast.toFixed(0)));
    this.bigaFlour.set(parseFloat(bigaFlour.toFixed(0)));
    this.bigaWater.set(parseFloat(bigaWater.toFixed(0)));
    this.doughFlour.set(parseFloat(doughFlour.toFixed(0)));
    this.doughWater.set(parseFloat(doughWater.toFixed(0)));
    this.numberOfPizzasTotal.set(parseFloat(numberOfPizzas.toFixed(0)));

    this.calculated.set(true);
    return;
  }
}
