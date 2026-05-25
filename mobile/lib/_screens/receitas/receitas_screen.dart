import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../_helpers/numero_helper.dart';
import '../../_models/dtos.dart';
import '../../_services/account_service.dart';
import '../../_services/receita_service.dart';
import '../../_theme/app_colors.dart';

class ReceitasScreen extends StatefulWidget {
  const ReceitasScreen({super.key});

  @override
  State<ReceitasScreen> createState() => _ReceitasScreenState();
}

class _ReceitasScreenState extends State<ReceitasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AccountService>().usuarioAtual?.token;
      context.read<ReceitaService>().retornaReceitas(token: token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ReceitaService>();
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: _buildAppBar(context, 'Receitas de Pão'),
      body:
          service.carregando
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              )
              : service.receitas.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book, size: 56, color: AppColors.border),
                    SizedBox(height: 12),
                    Text(
                      'Nenhuma receita disponível',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: service.receitas.length,
                itemBuilder: (context, index) {
                  final receita = service.receitas[index];
                  return _ReceitaCard(receita: receita);
                },
              ),
    );
  }
}

PreferredSizeWidget _buildAppBar(BuildContext context, String titulo) {
  return PreferredSize(
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
            Expanded(
              child: Text(
                titulo,
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
  );
}

class _ReceitaCard extends StatelessWidget {
  final ReceitaDto receita;
  const _ReceitaCard({required this.receita});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ReceitaDetalheScreen(receita: receita),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.iconReceitaBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.bakery_dining,
                    color: AppColors.iconReceitaFg,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receita.nome,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${receita.itens.length} ingrediente${receita.itens.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFd0c8c0),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReceitaDetalheScreen extends StatefulWidget {
  final ReceitaDto receita;
  const ReceitaDetalheScreen({super.key, required this.receita});

  @override
  State<ReceitaDetalheScreen> createState() => _ReceitaDetalheScreenState();
}

class _ReceitaDetalheScreenState extends State<ReceitaDetalheScreen> {
  int _quantidade = 1;
  ReceitaDto? _detalhe;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final service = context.read<ReceitaService>();
      await service.retornaDetalhe(widget.receita.id);
      if (mounted) setState(() => _detalhe = service.receitaAtual);
    });
  }

  List<_GrupoReceita> get _grupos {
    if (_detalhe == null) return [];
    final mapa = <int, _GrupoReceita>{};
    for (final item in _detalhe!.itens) {
      final grupoId = item.ingredienteGrupoId ?? -1;
      if (!mapa.containsKey(grupoId)) {
        mapa[grupoId] = _GrupoReceita(
          grupoId: grupoId,
          grupoNome: item.ingredienteGrupoNome,
          grupoOrdem: item.ingredienteGrupoOrdem,
          itens: [],
        );
      }
      mapa[grupoId]!.itens.add(item);
    }
    final lista = mapa.values.toList();
    lista.sort((a, b) => a.grupoOrdem.compareTo(b.grupoOrdem));
    return lista;
  }

  double get _totalPeso =>
      (_detalhe?.itens ?? []).fold(0.0, (s, i) => s + i.pesoG) * _quantidade;

  @override
  Widget build(BuildContext context) {
    final carregando = context.watch<ReceitaService>().carregandoDetalhe;
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
                    widget.receita.nome,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
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
      body:
          carregando
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              )
              : _detalhe == null
              ? const Center(
                child: Text(
                  'Erro ao carregar receita',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _QuantidadeBar(
                      quantidade: _quantidade,
                      onDecrementar:
                          _quantidade > 1
                              ? () => setState(() => _quantidade--)
                              : null,
                      onIncrementar: () => setState(() => _quantidade++),
                    ),
                    const SizedBox(height: 12),
                    ..._grupos.map(
                      (grupo) => _GrupoCard(
                        grupo: grupo,
                        quantidade: _quantidade,
                      ),
                    ),
                    if (_detalhe!.itens.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _TotalCard(totalPeso: _totalPeso),
                    ],
                    if (_detalhe!.modoPreparo.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _ModoPreparo(texto: _detalhe!.modoPreparo),
                    ],
                  ],
                ),
              ),
    );
  }
}

class _QuantidadeBar extends StatelessWidget {
  final int quantidade;
  final VoidCallback? onDecrementar;
  final VoidCallback onIncrementar;

  const _QuantidadeBar({
    required this.quantidade,
    required this.onDecrementar,
    required this.onIncrementar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Quantidade',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: onDecrementar,
                icon: const Icon(Icons.remove_circle_outline),
                color:
                    onDecrementar != null
                        ? AppColors.accent
                        : AppColors.border,
                iconSize: 22,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              SizedBox(
                width: 32,
                child: Text(
                  '$quantidade',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: onIncrementar,
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.accent,
                iconSize: 22,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GrupoReceita {
  final int grupoId;
  final String grupoNome;
  final int grupoOrdem;
  final List<ReceitaItemDto> itens;
  _GrupoReceita({
    required this.grupoId,
    required this.grupoNome,
    required this.grupoOrdem,
    required this.itens,
  });
}

class _GrupoCard extends StatelessWidget {
  final _GrupoReceita grupo;
  final int quantidade;

  const _GrupoCard({required this.grupo, required this.quantidade});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (grupo.grupoNome.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.layers, size: 14, color: AppColors.accent),
                const SizedBox(width: 5),
                Text(
                  grupo.grupoNome.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
        ...grupo.itens.map(
          (item) => _IngredienteRow(item: item, quantidade: quantidade),
        ),
      ],
    );
  }
}

class _IngredienteRow extends StatelessWidget {
  final ReceitaItemDto item;
  final int quantidade;

  const _IngredienteRow({required this.item, required this.quantidade});

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
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.ingredienteNome,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.ingredienteMarca.isNotEmpty)
                  Text(
                    item.ingredienteMarca,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${formatarDecimal(item.pesoG * quantidade)}g',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${formatarDecimal(item.percentual)}%',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final double totalPeso;
  const _TotalCard({required this.totalPeso});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.accentBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          Text(
            '${formatarDecimal(totalPeso)}g',
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModoPreparo extends StatelessWidget {
  final String texto;
  const _ModoPreparo({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.format_list_numbered,
                color: AppColors.accent,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'Modo de Preparo',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            texto,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
