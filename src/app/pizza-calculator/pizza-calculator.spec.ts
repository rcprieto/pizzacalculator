import { ComponentFixture, TestBed } from '@angular/core/testing';

import { PizzaCalculator } from './pizza-calculator';

describe('PizzaCalculator', () => {
  let component: PizzaCalculator;
  let fixture: ComponentFixture<PizzaCalculator>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [PizzaCalculator]
    })
    .compileComponents();

    fixture = TestBed.createComponent(PizzaCalculator);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
