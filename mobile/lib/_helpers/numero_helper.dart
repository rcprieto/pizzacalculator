import 'package:intl/intl.dart';

final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ', decimalDigits: 2);
final _inteiro = NumberFormat('#,##0', 'pt_BR');

String formatarMoeda(double valor) => _moeda.format(valor);

String formatarInteiro(double valor) => _inteiro.format(valor.round());

String formatarDecimal(double valor, {int casas = 1}) =>
    NumberFormat('#,##0.${'0' * casas}', 'pt_BR').format(valor);

double parsarDecimal(String texto) =>
    double.tryParse(texto.trim().replaceAll('.', '').replaceAll(',', '.')) ?? 0;
