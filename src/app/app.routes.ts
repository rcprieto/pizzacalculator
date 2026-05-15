import { Routes } from '@angular/router';
import { PizzaCalculatorComponent } from './pizza-calculator/pizza-calculator';
import { MenuComponent } from './menu/menu';
import { PaoComponent } from './pao/pao';
import { LoginComponent } from './login/login';
import { ReceitasComponent } from './receitas/receitas';
import { authGuard } from '../_guard/auth.guard';
import { AdminShellComponent } from './_components/admin/admin-shell/admin-shell.component';
import { IngredienteListaComponent } from './_components/admin/ingrediente/lista/ingrediente-lista.component';
import { IngredienteGrupoListaComponent } from './_components/admin/ingrediente-grupo/lista/ingrediente-grupo-lista.component';
import { ReceitaListaComponent } from './_components/admin/receita/lista/receita-lista.component';

export const routes: Routes = [
  { path: '', component: MenuComponent },
  { path: 'pizza', component: PizzaCalculatorComponent },
  { path: 'pao', component: PaoComponent },
  { path: 'login', component: LoginComponent },
  { path: 'receitas', component: ReceitasComponent },
  {
    path: 'admin',
    component: AdminShellComponent,
    canActivate: [authGuard],
    children: [
      { path: 'ingredientes', component: IngredienteListaComponent },
      { path: 'ingrediente-grupos', component: IngredienteGrupoListaComponent },
      { path: 'receitas', component: ReceitaListaComponent },
      { path: '', redirectTo: 'receitas', pathMatch: 'full' },
    ]
  },
  { path: '**', redirectTo: '' },
];
