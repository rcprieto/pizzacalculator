import { Routes } from '@angular/router';
import { PizzaCalculatorComponent } from './pizza-calculator/pizza-calculator';
import { MenuComponent } from './menu/menu';
import { PaoComponent } from './pao/pao';
import { LoginComponent } from './login/login';
import { ReceitasComponent } from './receitas/receitas';
import { authGuard, adminGuard } from '../_guard/auth.guard';
import { AdminShellComponent } from './_components/admin/admin-shell/admin-shell.component';
import { IngredienteListaComponent } from './_components/admin/ingrediente/lista/ingrediente-lista.component';
import { IngredienteGrupoListaComponent } from './_components/admin/ingrediente-grupo/lista/ingrediente-grupo-lista.component';
import { ReceitaListaComponent } from './_components/admin/receita/lista/receita-lista.component';
import { UsuarioListaComponent } from './_components/admin/usuario/lista/usuario-lista.component';

export const routes: Routes = [
  { path: '', component: MenuComponent },
  { path: 'pizza', component: PizzaCalculatorComponent },
  { path: 'pao', component: PaoComponent },
  { path: 'login', component: LoginComponent },
  { path: 'receitas', component: ReceitasComponent, canActivate: [authGuard] },
  {
    path: 'admin',
    component: AdminShellComponent,
    canActivate: [authGuard],
    children: [
      { path: 'receitas', component: ReceitaListaComponent },
      { path: 'ingredientes', component: IngredienteListaComponent, canActivate: [adminGuard] },
      { path: 'ingrediente-grupos', component: IngredienteGrupoListaComponent, canActivate: [adminGuard] },
      { path: 'usuarios', component: UsuarioListaComponent, canActivate: [adminGuard] },
      { path: '', redirectTo: 'receitas', pathMatch: 'full' },
    ]
  },
  { path: '**', redirectTo: '' },
];
