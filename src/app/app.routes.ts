import { Routes } from '@angular/router';
import { PizzaCalculatorComponent } from './pizza-calculator/pizza-calculator';
import { MenuComponent } from './menu/menu';
import { PaoComponent } from './pao/pao';

export const routes: Routes = [
  { path: '', component: MenuComponent },
  { path: 'pizza', component: PizzaCalculatorComponent },
  { path: 'pao', component: PaoComponent },
];
