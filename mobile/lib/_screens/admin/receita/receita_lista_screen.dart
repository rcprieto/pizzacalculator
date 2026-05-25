import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../_models/dtos.dart';
import '../../../_services/account_service.dart';
import '../../../_services/receita_service.dart';
import '../../../_theme/app_colors.dart';
import 'receita_modal.dart';

class ReceitaAdminListaScreen extends StatefulWidget {
  const ReceitaAdminListaScreen({super.key});

  @override
  State<ReceitaAdminListaScreen> createState() =>
      _ReceitaAdminListaScreenState();
}

class _ReceitaAdminListaScreenState extends State<ReceitaAdminListaScreen> {
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

  String get _token =>
      context.read<AccountService>().usuarioAtual?.token ?? '';

  void _carregar() {
    context.read<ReceitaService>().retornaReceitas(
      pageNumber: _pagina,
      search: _buscaCtrl.text,
      token: _token,
    );
  }

  void _abrirModal([ReceitaDto? item]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReceitaModal(item: item, onSalvar: _carregar),
      ),
    );
  }

  Future<void> _confirmarExclusao(ReceitaDto item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppColors.cardBg,
            title: const Text(
              'Excluir receita',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
            ),
            content: Text(
              'Deseja excluir "${item.nome}"?',
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
                  'Excluir',
                  style: TextStyle(color: AppColors.deleteFg),
                ),
              ),
            ],
          ),
    );
    if (confirmar == true && mounted) {
      final erro = await context
          .read<ReceitaService>()
          .excluir(item.id, _token);
      if (mounted && erro != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(erro),
            backgroundColor: AppColors.deleteFg,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ReceitaService>();
    final paginacao = service.paginatedResult?.pagination;
    return Column(
      children: [
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
                      const Icon(
                        Icons.search,
                        color: AppColors.textMuted,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          controller: _buscaCtrl,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Buscar receita...',
                            hintStyle: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
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
                  decoration: BoxDecoration(
                    gradient: AppColors.barGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: AppColors.borderLight),
        Expanded(
          child:
              service.carregando
                  ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                  : service.receitas.isEmpty
                  ? const Center(
                    child: Text(
                      'Nenhuma receita encontrada',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                  : ListView.separated(
                    itemCount: service.receitas.length,
                    separatorBuilder:
                        (_, _) => Container(
                          height: 1,
                          color: Colors.black.withValues(alpha: 0.04),
                        ),
                    itemBuilder: (context, index) {
                      final item = service.receitas[index];
                      return Container(
                        color: AppColors.cardBg,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.iconPizzaBg,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: const Icon(
                                Icons.bakery_dining,
                                color: AppColors.iconPizzaFg,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.nome,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${item.itens.length} ingrediente${item.itens.length != 1 ? 's' : ''}',
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _ActionBtn(
                                  bg: AppColors.editBg,
                                  fg: AppColors.editFg,
                                  icon: Icons.edit,
                                  onTap: () => _abrirModal(item),
                                ),
                                const SizedBox(width: 6),
                                _ActionBtn(
                                  bg: AppColors.deleteBg,
                                  fg: AppColors.deleteFg,
                                  icon: Icons.delete_outline,
                                  onTap: () => _confirmarExclusao(item),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
        ),
        if (paginacao != null && paginacao.totalPages > 1)
          Container(
            color: AppColors.cardBg,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color:
                      _pagina > 1 ? AppColors.textPrimary : AppColors.border,
                  onPressed:
                      _pagina > 1
                          ? () => setState(() {
                            _pagina--;
                            _carregar();
                          })
                          : null,
                ),
                Text(
                  'Página $_pagina de ${paginacao.totalPages}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color:
                      _pagina < paginacao.totalPages
                          ? AppColors.textPrimary
                          : AppColors.border,
                  onPressed:
                      _pagina < paginacao.totalPages
                          ? () => setState(() {
                            _pagina++;
                            _carregar();
                          })
                          : null,
                ),
              ],
            ),
          ),
      ],
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
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, color: fg, size: 16),
      ),
    );
  }
}
