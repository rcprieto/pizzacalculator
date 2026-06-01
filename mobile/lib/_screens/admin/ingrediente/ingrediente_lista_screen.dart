import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../_helpers/numero_helper.dart';
import '../../../_models/dtos.dart';
import '../../../_services/account_service.dart';
import '../../../_services/ingrediente_service.dart';
import '../../../_theme/app_colors.dart';
import 'ingrediente_modal.dart';

class IngredienteListaScreen extends StatefulWidget {
  const IngredienteListaScreen({super.key});

  @override
  State<IngredienteListaScreen> createState() => _IngredienteListaScreenState();
}

class _IngredienteListaScreenState extends State<IngredienteListaScreen> {
  final _buscaCtrl = TextEditingController();
  int _pagina = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  String get _token => context.read<AccountService>().usuarioAtual?.token ?? '';

  void _carregar() {
    context.read<IngredienteService>().retornaIngredientes(_token, pageNumber: _pagina, search: _buscaCtrl.text);
  }

  void _abrirModal([IngredienteDto? item]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => IngredienteModal(item: item, onSalvar: _carregar),
    );
  }

  Future<void> _confirmarExclusao(IngredienteDto item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text('Excluir ingrediente', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        content: Text('Deseja excluir "${item.nome}"?', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir', style: TextStyle(color: AppColors.deleteFg)),
          ),
        ],
      ),
    );
    if (confirmar == true && mounted) {
      final erro = await context.read<IngredienteService>().excluir(item.id, _token);
      if (mounted && erro != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro), backgroundColor: AppColors.deleteFg));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<IngredienteService>();
    final paginacao = service.paginatedResult?.pagination;
    return Column(
      children: [
        // Toolbar
        Container(
          color: AppColors.cardBg,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.pageBg,
                    border: Border.all(color: AppColors.border, width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      const Icon(Icons.search, color: AppColors.textMuted, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          controller: _buscaCtrl,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'Buscar ingrediente...',
                            hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                          onSubmitted: (_) {
                            _pagina = 1;
                            _carregar();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _abrirModal(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(gradient: AppColors.barGradient, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: AppColors.borderLight),
        // Lista
        Expanded(
          child: service.carregando
              ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
              : service.ingredientes.isEmpty
              ? const Center(
                  child: Text('Nenhum ingrediente encontrado', style: TextStyle(color: AppColors.textMuted)),
                )
              : ListView.separated(
                  itemCount: service.ingredientes.length,
                  separatorBuilder: (_, _) => Container(height: 1, color: Colors.black.withValues(alpha: 0.04)),
                  itemBuilder: (context, index) {
                    final item = service.ingredientes[index];
                    return _IngredienteItem(item: item, onEditar: () => _abrirModal(item), onExcluir: () => _confirmarExclusao(item));
                  },
                ),
        ),
        if (paginacao != null && paginacao.totalPages > 1)
          _PaginacaoBar(
            paginacaoAtual: _pagina,
            totalPaginas: paginacao.totalPages,
            onAnterior: _pagina > 1
                ? () => setState(() {
                    _pagina--;
                    _carregar();
                  })
                : null,
            onProximo: _pagina < paginacao.totalPages
                ? () => setState(() {
                    _pagina++;
                    _carregar();
                  })
                : null,
          ),
      ],
    );
  }
}

class _IngredienteItem extends StatelessWidget {
  final IngredienteDto item;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _IngredienteItem({required this.item, required this.onEditar, required this.onExcluir});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBg,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.iconReceitaBg, borderRadius: BorderRadius.circular(11)),
            child: const Icon(Icons.egg_alt, color: AppColors.iconReceitaFg, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nome,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    if (item.marca.isNotEmpty) ...[Text(item.marca, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)), const Text(' · ', style: TextStyle(color: AppColors.textMuted, fontSize: 12))],
                    Text("${formatarMoeda(item.preco)}/kg", style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionBtn(bg: AppColors.editBg, fg: AppColors.editFg, icon: Icons.edit, onTap: onEditar),
              const SizedBox(width: 6),
              _ActionBtn(bg: AppColors.deleteBg, fg: AppColors.deleteFg, icon: Icons.delete_outline, onTap: onExcluir),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final Color bg;
  final Color fg;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionBtn({required this.bg, required this.fg, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9)),
        child: Icon(icon, color: fg, size: 16),
      ),
    );
  }
}

class _PaginacaoBar extends StatelessWidget {
  final int paginacaoAtual;
  final int totalPaginas;
  final VoidCallback? onAnterior;
  final VoidCallback? onProximo;

  const _PaginacaoBar({required this.paginacaoAtual, required this.totalPaginas, required this.onAnterior, required this.onProximo});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBg,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), color: onAnterior != null ? AppColors.textPrimary : AppColors.border, onPressed: onAnterior),
          Text('Página $paginacaoAtual de $totalPaginas', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          IconButton(icon: const Icon(Icons.chevron_right), color: onProximo != null ? AppColors.textPrimary : AppColors.border, onPressed: onProximo),
        ],
      ),
    );
  }
}
