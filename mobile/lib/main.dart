import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '_router/app_router.dart';
import '_services/account_service.dart';
import '_services/ingrediente_service.dart';
import '_services/ingrediente_grupo_service.dart';
import '_services/receita_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final accountService = AccountService();
  await accountService.inicializar();
  runApp(PizzaCalculatorApp(accountService: accountService));
}

class PizzaCalculatorApp extends StatelessWidget {
  final AccountService accountService;

  const PizzaCalculatorApp({super.key, required this.accountService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: accountService),
        ChangeNotifierProvider(create: (_) => IngredienteService()),
        ChangeNotifierProvider(create: (_) => IngredienteGrupoService()),
        ChangeNotifierProvider(create: (_) => ReceitaService()),
      ],
      child: Builder(
        builder: (context) {
          final router = buildRouter(context.read<AccountService>());
          return MaterialApp.router(
            title: 'Calculadora Padaria',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.light(
                primary: const Color(0xFF1c0f0a),
                secondary: const Color(0xFFc07a0a),
                surface: const Color(0xFFf5f0eb),
              ),
              scaffoldBackgroundColor: const Color(0xFFf5f0eb),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1c0f0a),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
            routerConfig: router,
            builder: (context, child) => SafeArea(
              top: false,
              child: child!,
            ),
          );
        },
      ),
    );
  }
}
