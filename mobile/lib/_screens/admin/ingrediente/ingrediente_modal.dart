import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../_helpers/numero_helper.dart';
import '../../../_models/dtos.dart';
import '../../../_services/account_service.dart';
import '../../../_services/ingrediente_service.dart';
import '../../../_theme/app_colors.dart';

class IngredienteModal extends StatefulWidget {
  final IngredienteDto? item;
  final VoidCallback onSalvar;

  const IngredienteModal({super.key, this.item, required this.onSalvar});

  @override
  State<IngredienteModal> createState() => _IngredienteModalState();
}

class _IngredienteModalState extends State<IngredienteModal> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _marcaCtrl = TextEditingController();
  final _precoCtrl = TextEditingController();
  bool _status = true;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nomeCtrl.text = widget.item!.nome;
      _marcaCtrl.text = widget.item!.marca;
      _precoCtrl.text = formatarDecimal(widget.item!.preco, casas: 2);
      _status = widget.item!.status;
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _marcaCtrl.dispose();
    _precoCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final token = context.read<AccountService>().usuarioAtual?.token ?? '';
    final service = context.read<IngredienteService>();
    final model = IngredienteDto(
      id: widget.item?.id ?? 0,
      nome: _nomeCtrl.text.trim(),
      marca: _marcaCtrl.text.trim(),
      preco: parsarDecimal(_precoCtrl.text),
      status: _status,
    );
    final erro =
        widget.item != null
            ? await service.atualizar(model, token)
            : await service.cadastrar(model, token);
    if (!mounted) return;
    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: AppColors.deleteFg),
      );
    } else {
      Navigator.of(context).pop();
      widget.onSalvar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Salvo com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.item != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header com gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.barGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Text(
                  editando ? 'Editar Ingrediente' : 'Novo Ingrediente',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _campo(
                    controller: _nomeCtrl,
                    label: 'Nome',
                    obrigatorio: true,
                  ),
                  const SizedBox(height: 12),
                  _campo(controller: _marcaCtrl, label: 'Marca'),
                  const SizedBox(height: 12),
                  _campo(
                    controller: _precoCtrl,
                    label: 'Preço (R\$)',
                    teclado: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ativo',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      Switch(
                        value: _status,
                        activeThumbColor: AppColors.accent,
                        onChanged: (v) => setState(() => _status = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Footer
          Container(
            color: AppColors.modalFooterBg,
            padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.of(context).viewPadding.bottom),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _salvar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.barTop,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Salvar',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    bool obrigatorio = false,
    TextInputType? teclado,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: teclado,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.05,
        ),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      validator:
          obrigatorio
              ? (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null
              : null,
    );
  }
}
