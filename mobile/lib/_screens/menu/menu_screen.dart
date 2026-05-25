import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../_services/account_service.dart';
import '../../_theme/app_colors.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logado = context.watch<AccountService>().estaLogado;
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Column(
        children: [
          // Hero header com gradiente
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(gradient: AppColors.heroGradient),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 28,
              left: 24,
              right: 24,
            ),
            child: Column(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.11),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.local_pizza,
                    color: Color(0xFFe8a04d),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pizza Calculator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Receitas e calculadora de massa',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.58),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Cards de navegação
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  _MenuCard(
                    iconeBg: AppColors.iconReceitaBg,
                    iconeFg: AppColors.iconReceitaFg,
                    icone: Icons.menu_book,
                    titulo: 'Receitas',
                    subtitulo: 'Veja as receitas disponíveis',
                    onTap: () => context.go('/receitas'),
                  ),
                  const SizedBox(height: 10),
                  _MenuCard(
                    iconeBg: AppColors.iconPizzaBg,
                    iconeFg: AppColors.iconPizzaFg,
                    icone: Icons.calculate,
                    titulo: 'Calculadora de Pizza',
                    subtitulo: 'Calcule o peso da massa',
                    onTap: () => context.go('/pizza'),
                  ),
                  const SizedBox(height: 10),
                  _MenuCard(
                    iconeBg: AppColors.iconAdminBg,
                    iconeFg: AppColors.iconAdminFg,
                    icone: logado ? Icons.admin_panel_settings : Icons.lock,
                    titulo: logado ? 'Administração' : 'Área Administrativa',
                    subtitulo:
                        logado
                            ? 'Ingredientes, grupos e receitas'
                            : 'Faça login para acessar',
                    onTap:
                        () => context.go(logado ? '/admin/receitas' : '/login'),
                  ),
                  if (logado) ...[
                    const SizedBox(height: 24),
                    TextButton.icon(
                      onPressed: () async {
                        await context.read<AccountService>().logout();
                      },
                      icon: const Icon(
                        Icons.logout,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      label: const Text(
                        'Sair',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final Color iconeBg;
  final Color iconeFg;
  final IconData icone;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _MenuCard({
    required this.iconeBg,
    required this.iconeFg,
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconeBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icone, color: iconeFg, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitulo,
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
    );
  }
}
