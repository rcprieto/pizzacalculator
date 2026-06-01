import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../_helpers/numero_helper.dart';
import '../../../_models/dtos.dart';
import '../../../_services/account_service.dart';
import '../../../_services/ingrediente_service.dart';
import '../../../_services/ingrediente_grupo_service.dart';
import '../../../_services/receita_service.dart';
import '../../../_theme/app_colors.dart';

class ReceitaModal extends StatefulWidget {
  final ReceitaDto? item;
  final VoidCallback onSalvar;

  const ReceitaModal({super.key, this.item, required this.onSalvar});

  @override
  State<ReceitaModal> createState() => _ReceitaModalState();
}

class _ReceitaModalState extends State<ReceitaModal> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _modoPreparoCtrl = TextEditingController();
  bool _status = true;
  bool _salvando = false;
  ReceitaDto? _receitaSalva;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nomeCtrl.text = widget.item!.nome;
      _modoPreparoCtrl.text = widget.item!.modoPreparo;
      _status = widget.item!.status;
      _receitaSalva = widget.item;
      WidgetsBinding.instance.addPostFrameCallback((_) => _carregarDetalhe());
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _carregarIngredientes(),
    );
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _modoPreparoCtrl.dispose();
    super.dispose();
  }

  String get _token =>
      context.read<AccountService>().usuarioAtual?.token ?? '';

  Future<void> _carregarDetalhe() async {
    if (_receitaSalva == null) return;
    final service = context.read<ReceitaService>();
    await service.retornaDetalhe(_receitaSalva!.id, token: _token);
    if (mounted) setState(() => _receitaSalva = service.receitaAtual);
  }

  void _carregarIngredientes() {
    context.read<IngredienteService>().retornaTodos(_token);
    context.read<IngredienteGrupoService>().retornaTodos(_token);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    final service = context.read<ReceitaService>();
    final model = ReceitaDto(
      id: widget.item?.id ?? 0,
      nome: _nomeCtrl.text.trim(),
      modoPreparo: _modoPreparoCtrl.text.trim(),
      status: _status,
    );
    final erro =
        widget.item != null
            ? await service.atualizar(model, _token)
            : await service.cadastrar(model, _token);
    if (!mounted) return;
    setState(() => _salvando = false);
    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: AppColors.deleteFg),
      );
    } else {
      if (widget.item == null) {
        final nova = service.receitas.first;
        setState(() => _receitaSalva = nova);
        await service.retornaDetalhe(nova.id, token: _token);
        if (mounted) setState(() => _receitaSalva = service.receitaAtual);
      }
      widget.onSalvar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receita salva com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // Percentual baker's: farinha = 100%, demais = pesoG / pesoFarinha * 100
  String _percentualFarinha(ReceitaItemDto item, List<ReceitaItemDto> itens) {
    final farinha = itens.where((i) => i.ingredienteId == 1).firstOrNull;
    if (farinha == null || farinha.pesoG == 0) return '';
    final pct = item.ingredienteId == 1 ? 100.0 : (item.pesoG / farinha.pesoG) * 100;
    return '${formatarDecimal(pct, casas: 1)}%';
  }

  void _abrirModalItem([ReceitaItemDto? item]) {
    if (_receitaSalva == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Salve a receita antes de adicionar ingredientes'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => _ReceitaItemModal(
            receitaId: _receitaSalva!.id,
            item: item,
            onSalvar: _carregarDetalhe,
          ),
    );
  }

  Future<void> _excluirItem(ReceitaItemDto item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppColors.cardBg,
            title: const Text(
              'Remover ingrediente',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
            ),
            content: Text(
              'Remover "${item.ingredienteNome}"?',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Remover',
                  style: TextStyle(color: AppColors.deleteFg),
                ),
              ),
            ],
          ),
    );
    if (confirmar == true && mounted) {
      final erro = await context
          .read<ReceitaService>()
          .excluirItem(item.id, _token);
      if (mounted) {
        if (erro != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(erro),
              backgroundColor: AppColors.deleteFg,
            ),
          );
        } else {
          await _carregarDetalhe();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itens = _receitaSalva?.itens ?? [];
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
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Text(
                    widget.item != null ? 'Editar Receita' : 'Nova Receita',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Formulário
            Container(
              color: AppColors.cardBg,
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _campo(
                      controller: _nomeCtrl,
                      label: 'Nome da receita',
                      obrigatorio: true,
                    ),
                    const SizedBox(height: 12),
                    _campo(
                      controller: _modoPreparoCtrl,
                      label: 'Modo de preparo',
                      maxLines: 4,
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
            Container(
              color: AppColors.modalFooterBg,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: ElevatedButton(
                onPressed: _salvando ? null : _salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.barTop,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    _salvando
                        ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text(
                          'Salvar Receita',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
              ),
            ),
            const SizedBox(height: 8),
            // Ingredientes da receita
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'INGREDIENTES',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _abrirModalItem(),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.add,
                          size: 16,
                          color: AppColors.accent,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Adicionar',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (itens.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Nenhum ingrediente adicionado',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              )
            else
              Container(
                color: AppColors.cardBg,
                child: Column(
                  children: [
                    // Cabeçalho da tabela
                    Container(
                      color: AppColors.pageBg,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: Text(
                              'INGREDIENTE',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 55,
                            child: Text(
                              'PESO',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 52,
                            child: Text(
                              '% FARINHA',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          SizedBox(width: 70),
                        ],
                      ),
                    ),
                    Container(height: 1, color: AppColors.borderLight),
                    ...itens.map(
                      (item) => Column(
                        children: [
                          Container(
                            color: AppColors.cardBg,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.ingredienteNome,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (item.observacao.isNotEmpty)
                                        Text(
                                          item.observacao,
                                          style: const TextStyle(
                                            color: AppColors.accent,
                                            fontSize: 11,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 55,
                                  child: Text(
                                    '${formatarDecimal(item.pesoG, casas: 1)}g',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 52,
                                  child: Text(
                                    _percentualFarinha(item, itens),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _ActionBtn(
                                      bg: AppColors.editBg,
                                      fg: AppColors.editFg,
                                      icon: Icons.edit,
                                      onTap: () => _abrirModalItem(item),
                                    ),
                                    const SizedBox(width: 4),
                                    _ActionBtn(
                                      bg: AppColors.deleteBg,
                                      fg: AppColors.deleteFg,
                                      icon: Icons.delete_outline,
                                      onTap: () => _excluirItem(item),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 1,
                            color: Colors.black.withValues(alpha: 0.04),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    bool obrigatorio = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
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

class _ActionBtn extends StatelessWidget {
  final Color bg;
  final Color fg;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.bg,
    required this.fg,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: fg, size: 15),
      ),
    );
  }
}

class _ReceitaItemModal extends StatefulWidget {
  final int receitaId;
  final ReceitaItemDto? item;
  final Future<void> Function() onSalvar;

  const _ReceitaItemModal({
    required this.receitaId,
    this.item,
    required this.onSalvar,
  });

  @override
  State<_ReceitaItemModal> createState() => _ReceitaItemModalState();
}

class _ReceitaItemModalState extends State<_ReceitaItemModal> {
  final _pesoCtrl = TextEditingController();
  final _observacaoCtrl = TextEditingController();
  int? _ingredienteSelecionado;
  int? _grupoSelecionado;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _ingredienteSelecionado = widget.item!.ingredienteId;
      _grupoSelecionado = widget.item!.ingredienteGrupoId;
      _pesoCtrl.text = formatarDecimal(widget.item!.pesoG, casas: 1);
      _observacaoCtrl.text = widget.item!.observacao;
    }
  }

  @override
  void dispose() {
    _pesoCtrl.dispose();
    _observacaoCtrl.dispose();
    super.dispose();
  }

  String get _token =>
      context.read<AccountService>().usuarioAtual?.token ?? '';

  Future<void> _salvar() async {
    if (_ingredienteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um ingrediente'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final service = context.read<ReceitaService>();
    final model = ReceitaItemDto(
      id: widget.item?.id ?? 0,
      receitaId: widget.receitaId,
      ingredienteId: _ingredienteSelecionado!,
      ingredienteGrupoId: _grupoSelecionado,
      pesoG: parsarDecimal(_pesoCtrl.text),
      percentual: 0,
      observacao: _observacaoCtrl.text.trim(),
    );
    final erro =
        widget.item != null
            ? await service.atualizarItem(model, _token)
            : await service.adicionarItem(model, _token);
    if (!mounted) return;
    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: AppColors.deleteFg),
      );
    } else {
      Navigator.of(context).pop();
      await widget.onSalvar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ingredientes = context.watch<IngredienteService>().todos;
    final grupos = context.watch<IngredienteGrupoService>().todos;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.barGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Text(
                  widget.item != null
                      ? 'Editar Ingrediente'
                      : 'Adicionar Ingrediente',
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Autocomplete<IngredienteDto>(
                  displayStringForOption: (i) =>
                      i.marca.isNotEmpty ? '${i.nome} — ${i.marca}' : i.nome,
                  initialValue: TextEditingValue(
                    text: _ingredienteSelecionado == null
                        ? ''
                        : ingredientes
                              .where((i) => i.id == _ingredienteSelecionado)
                              .map((i) => i.marca.isNotEmpty
                                  ? '${i.nome} — ${i.marca}'
                                  : i.nome)
                              .firstOrNull ??
                          '',
                  ),
                  optionsBuilder: (value) {
                    if (value.text.isEmpty) return ingredientes;
                    final busca = value.text.toLowerCase();
                    return ingredientes.where((i) =>
                        i.nome.toLowerCase().contains(busca) ||
                        i.marca.toLowerCase().contains(busca));
                  },
                  onSelected: (i) =>
                      setState(() => _ingredienteSelecionado = i.id),
                  fieldViewBuilder: (ctx, ctrl, focusNode, _) => TextField(
                    controller: ctrl,
                    focusNode: focusNode,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Buscar ingrediente...',
                      hintStyle: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textMuted,
                        size: 18,
                      ),
                      filled: true,
                      fillColor: AppColors.inputBg,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.accent,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  optionsViewBuilder: (ctx, onSelected, options) => Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(10),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 220),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          itemBuilder: (_, i) {
                            final ing = options.elementAt(i);
                            return InkWell(
                              onTap: () => onSelected(ing),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ing.nome,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (ing.marca.isNotEmpty)
                                      Text(
                                        ing.marca,
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 11,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.inputBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: _grupoSelecionado,
                      hint: const Text(
                        'Sem grupo',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                      dropdownColor: AppColors.cardBg,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text(
                            'Sem grupo',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                        ...grupos.map(
                          (g) => DropdownMenuItem<int?>(
                            value: g.id,
                            child: Text(
                              g.nome,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _grupoSelecionado = v),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _campo(_pesoCtrl, 'Peso (g)'),
                const SizedBox(height: 10),
                _campo(_observacaoCtrl, 'Observação', numerico: false),
              ],
            ),
          ),
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

  Widget _campo(TextEditingController controller, String label, {bool numerico = true}) {
    return TextFormField(
      controller: controller,
      keyboardType: numerico
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
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
    );
  }
}
