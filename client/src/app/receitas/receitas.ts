import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { ReceitaService } from '../_services/receita.service';
import { ReceitaDto, ReceitaItemDto } from '../_models/dtos';
import { SumPipe } from '../_pipes/sum.pipe';

interface GrupoItens {
  grupoNome: string;
  grupoOrdem: number;
  itens: ReceitaItemDto[];
}

@Component({
  selector: 'app-receitas',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink, SumPipe],
  templateUrl: './receitas.html',
  styleUrl: './receitas.css',
})
export class ReceitasComponent implements OnInit {
  service = inject(ReceitaService);
  quantidade = 1;
  vistaAtiva: 'lista' | 'detalhe' = 'lista';

  get receitas() { return this.service.receitas(); }
  get detalhe() { return this.service.receitaAtual(); }

  ngOnInit() {
    this.service.retornaReceitas(1, 100, '', 'Nome', 'asc');
    this.service.receitaAtual.set(null);
  }

  selecionar(receita: ReceitaDto) {
    this.quantidade = 1;
    this.vistaAtiva = 'detalhe';
    this.service.retornaReceitaComItens(receita.id);
  }

  voltar() {
    this.vistaAtiva = 'lista';
  }

  incrementar() {
    this.quantidade++;
  }

  decrementar() {
    if (this.quantidade > 1) this.quantidade--;
  }

  get gruposReceita(): GrupoItens[] {
    const itens = this.detalhe?.itens ?? [];
    const map = new Map<number | null, GrupoItens>();

    for (const item of itens) {
      const key = item.ingredienteGrupoId ?? null;
      if (!map.has(key)) {
        map.set(key, {
          grupoNome: item.ingredienteGrupoNome ?? '',
          grupoOrdem: item.ingredienteGrupoOrdem ?? 9999,
          itens: []
        });
      }
      map.get(key)!.itens.push(item);
    }

    return [...map.values()].sort((a, b) => a.grupoOrdem - b.grupoOrdem);
  }
}
