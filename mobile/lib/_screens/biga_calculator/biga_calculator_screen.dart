import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../_helpers/numero_helper.dart';
import '../../_theme/app_colors.dart';

enum _ModoBiga { farinha, biga }

class BigaCalculatorScreen extends StatefulWidget {
  const BigaCalculatorScreen({super.key});

  @override
  State<BigaCalculatorScreen> createState() => _BigaCalculatorScreenState();
}

class _BigaCalculatorScreenState extends State<BigaCalculatorScreen> {
  // A biga leva 50% da farinha total, com água igual a 50% da farinha da biga
  static const _percentualFarinhaBiga = 0.5;
  static const _hidratacaoBiga = 0.5;
  static const _percentualSal = 0.02;

  final _quantidadeCtrl = TextEditingController();
  _ModoBiga _modo = _ModoBiga.farinha;
  int _hidratacao = 60;
  bool _calculado = false;

  late double _farinhaTotal;
  late double _aguaTotal;
  late double _bigaFarinha;
  late double _bigaAgua;
  late double _bigaPeso;
  late double _massaFarinha;
  late double _massaAgua;
  late double _sal;
  late double _massaTotal;
  late int _hidratacaoCalculada;

  @override
  void dispose() {
    _quantidadeCtrl.dispose();
    super.dispose();
  }

  void _selecionarModo(_ModoBiga modo) {
    if (_modo == modo) return;
    setState(() {
      _modo = modo;
      _quantidadeCtrl.clear();
      _calculado = false;
    });
  }

  void _calcular() {
    final quantidade = int.tryParse(_quantidadeCtrl.text);
    if (quantidade == null || quantidade <= 0) return;

    double bigaFarinha;
    double bigaAgua;

    if (_modo == _ModoBiga.farinha) {
      // Informado: farinha total da receita
      bigaFarinha = quantidade * _percentualFarinhaBiga;
      bigaAgua = bigaFarinha * _hidratacaoBiga;
    } else {
      // Informado: peso da biga pronta (farinha + 50% de água => peso / 1,5)
      bigaFarinha = quantidade / (1 + _hidratacaoBiga);
      bigaAgua = quantidade - bigaFarinha;
    }

    final farinhaTotal = bigaFarinha / _percentualFarinhaBiga;
    final aguaTotal = farinhaTotal * (_hidratacao / 100);
    final sal = farinhaTotal * _percentualSal;

    setState(() {
      _farinhaTotal = farinhaTotal;
      _aguaTotal = aguaTotal;
      _bigaFarinha = bigaFarinha;
      _bigaAgua = bigaAgua;
      _bigaPeso = bigaFarinha + bigaAgua;
      _massaFarinha = farinhaTotal - bigaFarinha;
      _massaAgua = aguaTotal - bigaAgua;
      _sal = sal;
      _massaTotal = farinhaTotal + aguaTotal + sal;
      _hidratacaoCalculada = _hidratacao;
      _calculado = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final porFarinha = _modo == _ModoBiga.farinha;
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
                    'Calculadora de Biga',
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
            _Secao('Calcular a partir de'),
            const SizedBox(height: 10),
            _seletorModo(),
            const SizedBox(height: 12),
            _campoNumero(
              controller: _quantidadeCtrl,
              label: porFarinha ? 'Farinha da receita (g)' : 'Peso da biga (g)',
              hint: porFarinha ? 'Ex: 1000' : 'Ex: 300',
            ),
            const SizedBox(height: 6),
            Text(
              porFarinha
                  ? 'A biga usa 50% da farinha, com 50% de água sobre ela.'
                  : 'Farinha da biga = peso ÷ 1,5 · o restante é água.',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
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
              Row(
                children: [
                  Expanded(
                    child: _CartaoResumo(label: 'Farinha total', valor: '${formatarInteiro(_farinhaTotal)}g', icone: Icons.grain, iconeBg: AppColors.accentBg, iconeFg: AppColors.accent),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _CartaoResumo(label: 'Água · $_hidratacaoCalculada%', valor: '${formatarInteiro(_aguaTotal)}g', icone: Icons.water_drop, iconeBg: AppColors.iconAdminBg, iconeFg: AppColors.iconAdminFg),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _CartaoResumo(label: 'Massa total', valor: '${formatarInteiro(_massaTotal)}g', icone: Icons.scale, iconeBg: AppColors.iconPizzaBg, iconeFg: AppColors.iconPizzaFg),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Secao('Biga (pré-fermento)'),
              const SizedBox(height: 8),
              _LinhaIngrediente(label: 'Farinha', valor: _bigaFarinha),
              _LinhaIngrediente(label: 'Água', valor: _bigaAgua),
              _LinhaIngrediente(label: 'Peso da biga', valor: _bigaPeso, destaque: true),
              const SizedBox(height: 16),
              _Secao('Massa final'),
              const SizedBox(height: 8),
              _LinhaIngrediente(label: 'Biga', valor: _bigaPeso),
              _LinhaIngrediente(label: 'Farinha (restante)', valor: _massaFarinha),
              _LinhaIngrediente(label: 'Água (restante)', valor: _massaAgua),
              _LinhaIngrediente(label: 'Sal (2%)', valor: _sal),
              _LinhaIngrediente(label: 'Massa total', valor: _massaTotal, destaque: true),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _seletorModo() {
    Widget opcao(_ModoBiga modo, IconData icone, String texto) {
      final ativo = _modo == modo;
      return Expanded(
        child: Material(
          color: ativo ? AppColors.barTop : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          child: InkWell(
            borderRadius: BorderRadius.circular(9),
            onTap: () => _selecionarModo(modo),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icone, size: 16, color: ativo ? Colors.white : AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    texto,
                    style: TextStyle(color: ativo ? Colors.white : AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          opcao(_ModoBiga.farinha, Icons.grain, 'Farinha total'),
          const SizedBox(width: 4),
          opcao(_ModoBiga.biga, Icons.scale, 'Peso da biga'),
        ],
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
                'Hidratação final',
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
              Text('70%', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
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
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _LinhaIngrediente extends StatelessWidget {
  final String label;
  final double valor;
  final bool destaque;

  const _LinhaIngrediente({required this.label, required this.valor, this.destaque = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: destaque ? AppColors.inputBg : AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: destaque ? AppColors.border : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: destaque ? FontWeight.bold : FontWeight.normal),
          ),
          Text(
            '${formatarDecimal(valor)}g',
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
