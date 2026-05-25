import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../_services/account_service.dart';
import '../../_theme/app_colors.dart';
import 'ingrediente/ingrediente_lista_screen.dart';
import 'ingrediente_grupo/ingrediente_grupo_lista_screen.dart';
import 'receita/receita_lista_screen.dart';
import 'usuario/usuario_lista_screen.dart';

class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _wasAdmin = false;

  static const _abasAdmin = [
    (icon: Icons.bakery_dining, label: 'Receitas'),
    (icon: Icons.egg_alt, label: 'Ingredientes'),
    (icon: Icons.layers, label: 'Grupos'),
    (icon: Icons.people, label: 'Usuários'),
  ];

  static const _abasUser = [
    (icon: Icons.bakery_dining, label: 'Receitas'),
  ];

  @override
  void initState() {
    super.initState();
    final isAdmin = context.read<AccountService>().isAdmin;
    _wasAdmin = isAdmin;
    _tabController = TabController(
      length: isAdmin ? _abasAdmin.length : _abasUser.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _reconstruirTabs(bool isAdmin) {
    if (_wasAdmin == isAdmin) return;
    _wasAdmin = isAdmin;
    _tabController.dispose();
    _tabController = TabController(
      length: isAdmin ? _abasAdmin.length : _abasUser.length,
      vsync: this,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountService>();
    final isAdmin = account.isAdmin;
    final email = account.usuarioAtual?.email ?? '';
    _reconstruirTabs(isAdmin);

    final abas = isAdmin ? _abasAdmin : _abasUser;

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
          tabs: abas
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
        children: [
          const ReceitaAdminListaScreen(),
          if (isAdmin) ...[
            const IngredienteListaScreen(),
            const IngredienteGrupoListaScreen(),
            const UsuarioListaScreen(),
          ],
        ],
      ),
    );
  }
}
