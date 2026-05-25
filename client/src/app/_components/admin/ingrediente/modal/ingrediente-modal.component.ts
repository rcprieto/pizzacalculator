import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { BsModalRef } from 'ngx-bootstrap/modal';
import { IngredienteService } from '../../../../_services/ingrediente.service';
import { IngredienteDto } from '../../../../_models/dtos';

@Component({
  selector: 'app-ingrediente-modal',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './ingrediente-modal.component.html',
})
export class IngredienteModalComponent implements OnInit {
  bsModalRef = inject(BsModalRef);
  private fb = inject(FormBuilder);
  private service = inject(IngredienteService);

  item: IngredienteDto | undefined;
  form: FormGroup = new FormGroup({});

  ngOnInit() {
    this.inicializarFormulario();
  }

  inicializarFormulario() {
    this.form = this.fb.group({
      id: [0],
      nome: ['', [Validators.required, Validators.maxLength(200)]],
      marca: ['', [Validators.maxLength(200)]],
      preco: [0, [Validators.required, Validators.min(0)]],
      status: [true],
    });
    if (this.item?.id) {
      this.form.patchValue(this.item);
    }
  }

  salvar() {
    if (this.form.invalid) return;
    const model: IngredienteDto = this.form.value;
    if (model.id > 0) {
      this.service.atualizar(model);
    } else {
      this.service.cadastrar(model);
    }
    this.bsModalRef.hide();
  }

  get f() { return this.form.controls; }
}
