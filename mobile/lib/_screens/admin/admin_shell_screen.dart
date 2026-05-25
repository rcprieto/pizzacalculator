import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../_services/account_service.dart';
import '../../_theme/app_colors.dart';
import 'ingrediente/ingrediente_lista_screen.dart';
import 'ingrediente_grupo/ingrediente_grupo_lista_screen.dart';
import 'receita/receita_lista_screen.dart';

class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _abas = [
    (icon: Icons.bakery_dining, label: 'Receitas'),
    (icon: Icons.egg_alt, label: 'Ingredientes'),
    (icon: Icons.layers, label: 'Grupos'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _abas.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email =
        context.watch<AccountService>().usuarioAtual?.email ?? '';
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.barGradient),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/'),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Administração',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (email.isNotEmpty)
              Text(
                email,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            tooltip: 'Sair',
            onPressed: () async {
              await context.read<AccountService>().logout();
              if (context.mounted) context.go('/');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFe8a04d),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          tabs: _abas
              .map(
                (a) => Tab(
                  icon: Icon(a.icon, size: 18),
                  text: a.label,
                  iconMargin: const EdgeInsets.only(bottom: 2),
                ),
              )
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ReceitaAdminListaScreen(),
          IngredienteListaScreen(),
          IngredienteGrupoListaScreen(),
        ],
      ),
    );
  }
}
