import { Component, inject } from '@angular/core';
import { RouterLink } from '@angular/router';
import { AccountService } from '../_services/account.service';

@Component({
  selector: 'app-menu',
  standalone: true,
  imports: [RouterLink],
  templateUrl: './menu.html',
  styleUrl: './menu.css',
})
export class MenuComponent {
  accountService = inject(AccountService);

  get adminRoute() {
    return this.accountService.currentUser() ? '/admin/receitas' : '/login';
  }
}
