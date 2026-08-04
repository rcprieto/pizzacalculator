import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../_helpers/numero_helper.dart';
import '../../_theme/app_colors.dart';

class PizzaCalculatorScreen extends StatefulWidget {
  const PizzaCalculatorScreen({super.key});

  @override
  State<PizzaCalculatorScreen> createState() => _PizzaCalculatorScreenState();
}

class _PizzaCalculatorScreenState extends State<PizzaCalculatorScreen> {
  final _quantidadeCtrl = TextEditingController();
  int _hidratacao = 60;
  String _tipo = 'P30';
  bool _calculado = false;

  late double _totalFarinha;
  late double _totalAgua;
  late double _sal;
  late double _fermento;
  late double _bigaFarinha;
  late double _bigaAgua;
  late double _massaFarinha;
  late double _massaAgua;
  late double _totalMassa;
  late int _totalPizzas;
  late int _totalPessoas;

  final _tipos = const [('P30', 'Pizzas 30cm (1 pizza / pessoa)'), ('P40', 'Pizzas 40cm (1 pizza / 2 pessoas)'), ('PE30', 'Pessoas (0.8 pizza 30cm / pessoa)'), ('PE40', 'Pessoas (0.5 pizza 40cm / pessoa)')];

  @override
  void dispose() {
    _quantidadeCtrl.dispose();
    super.dispose();
  }

  void _calcular() {
    final quantidade = int.tryParse(_quantidadeCtrl.text);
    if (quantidade == null || quantidade <= 0) return;

    double pizzaPorPessoa = 1;
    double massaPorPizza = 250;

    if (_tipo == 'PE30') pizzaPorPessoa = 0.8;
    if (_tipo == 'PE40') pizzaPorPessoa = 0.5;
    if (_tipo == 'P40' || _tipo == 'PE40') massaPorPizza = 300;

    final numPizzas = quantidade * pizzaPorPessoa;
    final totalDough = numPizzas.floor() * massaPorPizza;
    final hidDecimal = _hidratacao / 100;

    final farinha = totalDough / (1 + hidDecimal);
    final agua = totalDough - farinha;
    final sal = farinha * 0.02;
    final fermento = farinha / 500;
    final bigaFarinha = farinha / 2;
    final bigaAgua = bigaFarinha * 0.5;
    final massaFarinha = farinha - bigaFarinha;
    final massaAgua = agua - bigaAgua;

    int totalP;
    if (_tipo == 'PE30' || _tipo == 'PE40') {
      totalP = quantidade;
    } else {
      final ppp = _tipo == 'P30' ? 0.8 : 0.5;
      totalP = (numPizzas / ppp).round();
    }

    setState(() {
      _totalFarinha = double.parse(farinha.toStringAsFixed(1));
      _totalAgua = double.parse(agua.toStringAsFixed(1));
      _sal = double.parse(sal.toStringAsFixed(1));
      _fermento = double.parse(fermento.toStringAsFixed(1));
      _bigaFarinha = double.parse(bigaFarinha.toStringAsFixed(1));
      _bigaAgua = double.parse(bigaAgua.toStringAsFixed(1));
      _massaFarinha = double.parse(massaFarinha.toStringAsFixed(1));
      _massaAgua = double.parse(massaAgua.toStringAsFixed(1));
      _totalMassa = totalDough;
      _totalPizzas = numPizzas.floor();
      _totalPessoas = totalP;
      _calculado = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: const BoxDecoration(gradient: AppColors.barGradient),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.go('/'),
                ),
                const Expanded(
                  child: Text(
                    'Calculadora de Pizza',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Secao('Configuração'),
            const SizedBox(height: 10),
            _campoNumero(controller: _quantidadeCtrl, label: 'Quantidade', hint: 'Ex: 10'),
            const SizedBox(height: 12),
            _dropdownTipo(),
            const SizedBox(height: 12),
            _sliderHidratacao(),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _calcular,
                icon: const Icon(Icons.calculate, size: 18),
                label: const Text('Calcular', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.barTop,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            if (_calculado) ...[
              const SizedBox(height: 24),
              _Secao('Resultado'),
              const SizedBox(height: 10),
              _ResultadoResumo(totalPizzas: _totalPizzas, totalPessoas: _totalPessoas, totalMassa: _totalMassa),
              const SizedBox(height: 16),
              _Secao('Ingredientes Totais'),
              const SizedBox(height: 8),
              _LinhaIngrediente(label: 'Farinha total', valor: _totalFarinha),
              _LinhaIngrediente(label: 'Água total', valor: _totalAgua),
              _LinhaIngrediente(label: 'Sal', valor: _sal),
              _LinhaIngrediente(label: 'Fermento seco', valor: _fermento),
              const SizedBox(height: 16),
              _Secao('Biga (pré-fermento)'),
              const SizedBox(height: 8),
              _LinhaIngrediente(label: 'Farinha (biga)', valor: _bigaFarinha),
              _LinhaIngrediente(label: 'Água (biga)', valor: _bigaAgua),
              const SizedBox(height: 16),
              _Secao('Massa final'),
              const SizedBox(height: 8),
              _LinhaIngrediente(label: 'Farinha (massa)', valor: _massaFarinha),
              _LinhaIngrediente(label: 'Água (massa)', valor: _massaAgua),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _campoNumero({required TextEditingController controller, required String label, required String hint}) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
        filled: true,
        fillColor: AppColors.inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }

  Widget _dropdownTipo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _tipo,
          dropdownColor: AppColors.cardBg,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          isExpanded: true,
          items: _tipos.map((t) => DropdownMenuItem(value: t.$1, child: Text(t.$2))).toList(),
          onChanged: (v) => setState(() => _tipo = v!),
        ),
      ),
    );
  }

  Widget _sliderHidratacao() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hidratação',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Text(
                '$_hidratacao%',
                style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(activeTrackColor: AppColors.accent, inactiveTrackColor: AppColors.border, thumbColor: AppColors.accent, overlayColor: AppColors.accent.withValues(alpha: 0.1)),
            child: Slider(value: _hidratacao.toDouble(), min: 55, max: 85, divisions: 30, onChanged: (v) => setState(() => _hidratacao = v.round())),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('55%', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              Text('70% recomendado', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              Text('85%', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  final String titulo;
  const _Secao(this.titulo);

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo.toUpperCase(),
      style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.6),
    );
  }
}

class _ResultadoResumo extends StatelessWidget {
  final int totalPizzas;
  final int totalPessoas;
  final double totalMassa;

  const _ResultadoResumo({required this.totalPizzas, required this.totalPessoas, required this.totalMassa});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CartaoResumo(label: 'Pizzas', valor: '$totalPizzas', icone: Icons.local_pizza, iconeBg: AppColors.iconPizzaBg, iconeFg: AppColors.iconPizzaFg),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _CartaoResumo(label: 'Pessoas', valor: '$totalPessoas', icone: Icons.people, iconeBg: AppColors.iconAdminBg, iconeFg: AppColors.iconAdminFg),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _CartaoResumo(label: 'Massa', valor: '${formatarInteiro(totalMassa)}g', icone: Icons.scale, iconeBg: AppColors.accentBg, iconeFg: AppColors.accent),
        ),
      ],
    );
  }
}

class _CartaoResumo extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icone;
  final Color iconeBg;
  final Color iconeFg;

  const _CartaoResumo({required this.label, required this.valor, required this.icone, required this.iconeBg, required this.iconeFg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconeBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icone, color: iconeFg, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            valor,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _LinhaIngrediente extends StatelessWidget {
  final String label;
  final double valor;

  const _LinhaIngrediente({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
          Text(
            '${valor}g',
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
