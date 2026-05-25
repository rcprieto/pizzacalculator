import { Pipe, PipeTransform } from '@angular/core';

@Pipe({ name: 'sum', standalone: true })
export class SumPipe implements PipeTransform {
  transform(items: any[], field: string): number {
    if (!items) return 0;
    return items.reduce((acc, item) => acc + (Number(item[field]) || 0), 0);
  }
}
