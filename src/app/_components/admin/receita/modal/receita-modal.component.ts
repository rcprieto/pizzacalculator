import { Component, effect, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { FormsModule } from '@angular/forms';
import { BsModalRef } from 'ngx-bootstrap/modal';
import { ReceitaService } from '../../../../_services/receita.service';
import { IngredienteService } from '../../../../_services/ingrediente.service';
import { ReceitaDto, ReceitaItemDto } from '../../../../_models/dtos';

@Component({
  selector: 'app-receita-modal',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, FormsModule],
  templateUrl: './receita-modal.component.html',
})
export class ReceitaModalComponent implements OnInit {
  bsModalRef = inject(BsModalRef);
  private fb = inject(FormBuilder);
  service = inject(ReceitaService);
  ingredienteService = inject(IngredienteService);

  item: ReceitaDto | undefined;
  form: FormGroup = new FormGroup({});

  constructor() {
    effect(() => {
      const r = this.service.receitaAtual();
      if (r && r.id > 0 && this.form.value.id === 0) {
        this.form.patchValue({ id: r.id });
      }
    });
  }

  ingredienteIdSelecionado = 0;
  pesoGItem = 0;
  percentualItem = 0;
  observacaoItem = '';
  editandoItemId: number | null = null;

  get receita() {
    return this.service.receitaAtual();
  }
  get ingredientes() {
    return this.ingredienteService.todos();
  }

  get totalPesoG(): number {
    return this.receita?.itens?.reduce((acc, i) => acc + i.pesoG, 0) ?? 0;
  }

  get totalPercentual(): number {
    return this.receita?.itens?.reduce((acc, i) => acc + i.percentual, 0) ?? 0;
  }

  get totalCusto(): number {
    return this.receita?.itens?.reduce((acc, i) => acc + (i.pesoG * i.ingredientePreco / 1000), 0) ?? 0;
  }

  ngOnInit() {
    this.ingredienteService.retornaTodos();
    this.inicializarFormulario();
    if (this.item?.id) {
      this.service.retornaReceitaComItens(this.item.id);
    } else {
      this.service.receitaAtual.set({ id: 0, nome: '', modoPreparo: '', status: true, itens: [] });
    }
  }

  inicializarFormulario() {
    this.form = this.fb.group({
      id: [0],
      nome: ['', [Validators.required, Validators.maxLength(200)]],
      modoPreparo: [''],
      status: [true],
    });
    if (this.item?.id) {
      this.form.patchValue(this.item);
    }
  }

  salvarReceita() {
    if (this.form.invalid) return;
    const model: ReceitaDto = { ...this.form.value, itens: [] };
    if (model.id > 0) {
      this.service.atualizar(model);
    } else {
      this.service.cadastrar(model);
    }
  }

  adicionarItem() {
    const receitaId = this.receita?.id ?? this.form.value.id;
    if (!receitaId || receitaId === 0 || !this.ingredienteIdSelecionado) return;

    const ing = this.ingredientes.find(i => i.id === Number(this.ingredienteIdSelecionado));
    const novoItem: ReceitaItemDto = {
      id: 0,
      receitaId,
      ingredienteId: this.ingredienteIdSelecionado,
      ingredienteNome: ing?.nome ?? '',
      ingredienteMarca: ing?.marca ?? '',
      pesoG: this.pesoGItem,
      percentual: this.percentualItem,
      observacao: this.observacaoItem,
      ingredientePreco: ing?.preco ?? 0,
    };

    if (this.editandoItemId) {
      novoItem.id = this.editandoItemId;
      this.service.atualizarItem(novoItem);
      this.editandoItemId = null;
    } else {
      this.service.adicionarItem(receitaId, novoItem);
    }
    this.limparFormItem();
  }

  editarItem(item: ReceitaItemDto) {
    this.editandoItemId = item.id;
    this.ingredienteIdSelecionado = item.ingredienteId;
    this.pesoGItem = item.pesoG;
    this.percentualItem = item.percentual;
    this.observacaoItem = item.observacao ?? '';
  }

  confirmarExclusaoItem(item: ReceitaItemDto) {
    if (confirm(`Remover "${item.ingredienteNome}" da receita?`)) {
      this.service.excluirItem(item.id);
    }
  }

  limparFormItem() {
    this.ingredienteIdSelecionado = 0;
    this.pesoGItem = 0;
    this.percentualItem = 0;
    this.observacaoItem = '';
    this.editandoItemId = null;
  }

  fechar() {
    this.service.receitaAtual.set(null);
    this.bsModalRef.hide();
  }

  get f() {
    return this.form.controls;
  }
}
