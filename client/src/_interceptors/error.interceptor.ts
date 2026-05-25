import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { ToastrService } from 'ngx-toastr';
import { catchError, throwError } from 'rxjs';

export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  const router = inject(Router);
  const toastr = inject(ToastrService);

  return next(req).pipe(
    catchError(error => {
      if (error) {
        switch (error.status) {
          case 400:
            toastr.error(error.error || 'Requisição inválida');
            break;
          case 401:
            toastr.error('Não autorizado');
            router.navigateByUrl('/login');
            break;
          case 404:
            toastr.error('Recurso não encontrado');
            break;
          case 500:
            toastr.error('Erro interno no servidor');
            break;
          default:
            toastr.error('Erro desconhecido');
        }
      }
      return throwError(() => error);
    })
  );
};
