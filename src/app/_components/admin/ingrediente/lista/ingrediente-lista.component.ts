import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { BsModalRef, BsModalService } from 'ngx-bootstrap/modal';
import { PaginationModule } from 'ngx-bootstrap/pagination';
import { IngredienteService } from '../../../../_services/ingrediente.service';
import { IngredienteDto } from '../../../../_models/dtos';
import { IngredienteModalComponent } from '../modal/ingrediente-modal.component';
import { Pagination } from '../../../../../_helpers/pagination';

@Component({
  selector: 'app-ingrediente-lista',
  standalone: true,
  imports: [CommonModule, FormsModule, PaginationModule],
  templateUrl: './ingrediente-lista.component.html',
})
export class IngredienteListaComponent implements OnInit {
  service = inject(IngredienteService);
  private modalService = inject(BsModalService);

  pageNumber = 1;
  pageSize = 10;
  search = '';
  bsModalRef?: BsModalRef;

  get ingredientes() { return this.service.ingredientes(); }
  get pagination(): Pagination | undefined { return this.service.paginatedResult().pagination; }

  ngOnInit() {
    this.carregar();
  }

  carregar() {
    this.service.retornaIngredientes(this.pageNumber, this.pageSize, this.search);
  }

  buscar() {
    this.pageNumber = 1;
    this.carregar();
  }

  pageChanged(event: any) {
    this.pageNumber = event.page;
    this.carregar();
  }

  abrirModal(item?: IngredienteDto) {
    this.bsModalRef = this.modalService.show(IngredienteModalComponent, {
      class: 'modal-md',
      initialState: { item }
    });
  }

  confirmarExclusao(item: IngredienteDto) {
    if (confirm(`Excluir "${item.nome}"?`)) {
      this.service.excluir(item.id);
    }
  }
}
