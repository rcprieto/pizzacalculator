import { Component, inject } from '@angular/core';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { Router } from '@angular/router';
import { AccountService } from '../../../_services/account.service';

@Component({
  selector: 'app-admin-shell',
  standalone: true,
  imports: [RouterLink, RouterLinkActive, RouterOutlet],
  templateUrl: './admin-shell.component.html',
})
export class AdminShellComponent {
  accountService = inject(AccountService);
  private router = inject(Router);

  get email() { return this.accountService.currentUser()?.email ?? ''; }
  get isAdmin() { return this.accountService.isAdmin(); }

  sair() {
    this.accountService.logout();
    this.router.navigateByUrl('/');
  }
}
