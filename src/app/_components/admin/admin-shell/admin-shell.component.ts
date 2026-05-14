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
  private accountService = inject(AccountService);
  private router = inject(Router);

  sair() {
    this.accountService.logout();
    this.router.navigateByUrl('/');
  }
}
