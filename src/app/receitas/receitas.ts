import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { ReceitaService } from '../_services/receita.service';
import { ReceitaDto } from '../_models/dtos';
import { SumPipe } from '../_pipes/sum.pipe';

@Component({
  selector: 'app-receitas',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink, SumPipe],
  templateUrl: './receitas.html',
})
export class ReceitasComponent implements OnInit {
  service = inject(ReceitaService);
  quantidade = 1;

  get receitas() { return this.service.receitas(); }
  get detalhe() { return this.service.receitaAtual(); }

  ngOnInit() {
    this.service.retornaReceitas(1, 100, '', 'Nome', 'asc');
    this.service.receitaAtual.set(null);
  }

  selecionar(receita: ReceitaDto) {
    this.quantidade = 1;
    this.service.retornaReceitaComItens(receita.id);
  }
}
