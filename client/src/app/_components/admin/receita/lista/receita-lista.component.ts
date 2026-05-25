import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { BsModalRef, BsModalService } from 'ngx-bootstrap/modal';
import { PaginationModule } from 'ngx-bootstrap/pagination';
import { ReceitaService } from '../../../../_services/receita.service';
import { ReceitaDto } from '../../../../_models/dtos';
import { ReceitaModalComponent } from '../modal/receita-modal.component';
import { Pagination } from '../../../../../_helpers/pagination';

@Component({
  selector: 'app-receita-lista',
  standalone: true,
  imports: [CommonModule, FormsModule, PaginationModule],
  templateUrl: './receita-lista.component.html',
})
export class ReceitaListaComponent implements OnInit {
  service = inject(ReceitaService);
  private modalService = inject(BsModalService);

  pageNumber = 1;
  pageSize = 10;
  search = '';
  bsModalRef?: BsModalRef;

  get receitas() { return this.service.receitas(); }
  get pagination(): Pagination | undefined { return this.service.paginatedResult().pagination; }

  ngOnInit() {
    this.carregar();
  }

  carregar() {
    this.service.retornaReceitas(this.pageNumber, this.pageSize, this.search);
  }

  buscar() {
    this.pageNumber = 1;
    this.carregar();
  }

  pageChanged(event: any) {
    this.pageNumber = event.page;
    this.carregar();
  }

  abrirModal(item?: ReceitaDto) {
    this.bsModalRef = this.modalService.show(ReceitaModalComponent, {
      class: 'modal-xl',
      initialState: { item }
    });
  }

  confirmarExclusao(item: ReceitaDto) {
    if (confirm(`Excluir "${item.nome}"?`)) {
      this.service.excluir(item.id);
    }
  }

  calcularPreco(receita: ReceitaDto): number {
    return receita.itens?.reduce((acc, i) => acc + (i.pesoG * i.ingredientePreco / 1000), 0) ?? 0;
  }
}
