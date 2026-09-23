import 'package:go_router/go_router.dart';
import '../_screens/admin/admin_shell_screen.dart';
import '../_screens/biga_calculator/biga_calculator_screen.dart';
import '../_screens/login/login_screen.dart';
import '../_screens/menu/menu_screen.dart';
import '../_screens/pizza_calculator/pizza_calculator_screen.dart';
import '../_screens/receitas/receitas_screen.dart';
import '../_services/account_service.dart';

GoRouter buildRouter(AccountService accountService) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final logado = accountService.estaLogado;
      final rotaProtegida = state.matchedLocation.startsWith('/admin') ||
          state.matchedLocation.startsWith('/receitas');
      if (rotaProtegida && !logado) {
        final from = Uri.encodeComponent(state.matchedLocation);
        return '/login?from=$from';
      }
      return null;
    },
    refreshListenable: accountService,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MenuScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            LoginScreen(rotaOrigem: state.uri.queryParameters['from']),
      ),
      GoRoute(
        path: '/receitas',
        builder: (context, state) => const ReceitasScreen(),
      ),
      GoRoute(
        path: '/pizza',
        builder: (context, state) => const PizzaCalculatorScreen(),
      ),
      GoRoute(
        path: '/biga',
        builder: (context, state) => const BigaCalculatorScreen(),
      ),
      GoRoute(
        path: '/admin/receitas',
        builder: (context, state) => const AdminShellScreen(),
      ),
      GoRoute(
        path: '/admin/ingredientes',
        builder: (context, state) => const AdminShellScreen(),
      ),
      GoRoute(
        path: '/admin/grupos',
        builder: (context, state) => const AdminShellScreen(),
      ),
    ],
  );
}
