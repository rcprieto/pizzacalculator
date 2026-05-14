import { HttpParams } from '@angular/common/http';

export interface Pagination {
  currentPage: number;
  itemsPerPage: number;
  totalItems: number;
  totalPages: number;
}

export interface PaginatedResult<T> {
  result?: T;
  pagination?: Pagination;
}

export function setPaginationHeader(pageNumber: number, pageSize: number, search: string = '', orderBy: string = 'Nome', order: string = 'asc'): HttpParams {
  let params = new HttpParams();
  params = params.append('pageNumber', pageNumber.toString());
  params = params.append('pageSize', pageSize.toString());
  if (search) params = params.append('search', search);
  params = params.append('orderBy', orderBy);
  params = params.append('order', order);
  return params;
}
