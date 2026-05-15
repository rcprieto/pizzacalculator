import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { BsModalRef, BsModalService } from 'ngx-bootstrap/modal';
import { PaginationModule } from 'ngx-bootstrap/pagination';
import { IngredienteGrupoService } from '../../../../_services/ingrediente-grupo.service';
import { IngredienteGrupoDto } from '../../../../_models/dtos';
import { IngredienteGrupoModalComponent } from '../modal/ingrediente-grupo-modal.component';
import { Pagination } from '../../../../../_helpers/pagination';

@Component({
  selector: 'app-ingrediente-grupo-lista',
  standalone: true,
  imports: [CommonModule, FormsModule, PaginationModule],
  templateUrl: './ingrediente-grupo-lista.component.html',
})
export class IngredienteGrupoListaComponent implements OnInit {
  service = inject(IngredienteGrupoService);
  private modalService = inject(BsModalService);

  pageNumber = 1;
  pageSize = 10;
  search = '';
  bsModalRef?: BsModalRef;

  get grupos() { return this.service.grupos(); }
  get pagination(): Pagination | undefined { return this.service.paginatedResult().pagination; }

  ngOnInit() {
    this.carregar();
  }

  carregar() {
    this.service.retornaGrupos(this.pageNumber, this.pageSize, this.search, 'Ordem', 'asc');
  }

  buscar() {
    this.pageNumber = 1;
    this.carregar();
  }

  pageChanged(event: any) {
    this.pageNumber = event.page;
    this.carregar();
  }

  abrirModal(item?: IngredienteGrupoDto) {
    this.bsModalRef = this.modalService.show(IngredienteGrupoModalComponent, {
      class: 'modal-md',
      initialState: { item }
    });
  }

  confirmarExclusao(item: IngredienteGrupoDto) {
    if (confirm(`Excluir "${item.nome}"?`)) {
      this.service.excluir(item.id);
    }
  }
}
