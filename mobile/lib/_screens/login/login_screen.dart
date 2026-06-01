import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../_helpers/biometric_helper.dart';
import '../../_helpers/credentials_helper.dart';
import '../../_models/dtos.dart';
import '../../_services/account_service.dart';
import '../../_theme/app_colors.dart';
import 'cadastro_screen.dart';
import 'esqueci_senha_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? rotaOrigem;
  const LoginScreen({super.key, this.rotaOrigem});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _verSenha = false;
  bool _mostrarBiometria = false;

  @override
  void initState() {
    super.initState();
    _carregarCredenciais();
  }

  Future<void> _carregarCredenciais() async {
    final credenciais = await carregarCredenciais();
    if (!mounted) return;
    if (credenciais != null) {
      setState(() {
        _emailCtrl.text = credenciais.email;
        _senhaCtrl.text = credenciais.senha;
      });
      final biometriaAtiva = await getBiometriaAtiva();
      final disponivel = await biometriaDisponivel();
      if (biometriaAtiva == true && disponivel && mounted) {
        setState(() => _mostrarBiometria = true);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _entrarComBiometria(credenciais.email, credenciais.senha);
        });
      }
    }
  }

  Future<void> _entrarComBiometria(String email, String senha) async {
    final erro = await autenticarBiometria();
    if (!mounted) return;
    if (erro != null) {
      // Usuário cancelou (null silencioso) ou erro real — mostra só se for erro real
      if (!erro.contains('reconhecida')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(erro), backgroundColor: AppColors.deleteFg),
        );
      }
      return;
    }
    final service = context.read<AccountService>();
    final erroLogin = await service.login(LoginDto(email: email, password: senha));
    if (!mounted) return;
    if (erroLogin != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erroLogin), backgroundColor: AppColors.deleteFg),
      );
      return;
    }
    context.go(widget.rotaOrigem ?? '/admin/receitas');
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailCtrl.text.trim();
    final senha = _senhaCtrl.text;
    final service = context.read<AccountService>();
    final erro = await service.login(LoginDto(email: email, password: senha));
    if (!mounted) return;
    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: AppColors.deleteFg),
      );
      return;
    }
    await _perguntarSalvarCredenciais(email, senha);
    await _perguntarBiometria(email, senha);
    if (mounted) context.go(widget.rotaOrigem ?? '/admin/receitas');
  }

  Future<void> _perguntarBiometria(String email, String senha) async {
    if (!await biometriaDisponivel()) return;
    if (await carregarCredenciais() == null) return;
    if (await getBiometriaAtiva() != null) return; // já configurado
    if (!mounted) return;

    final ativar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.fingerprint, color: AppColors.accent, size: 22),
            SizedBox(width: 8),
            Text(
              'Ativar biometria',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
            ),
          ],
        ),
        content: const Text(
          'Deseja usar digital ou reconhecimento facial para entrar nas próximas vezes?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Não', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Ativar',
              style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    await setBiometriaAtiva(ativar ?? false);
  }

  void _abrirEsqueciSenha() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EsqueciSenhaScreen(emailInicial: _emailCtrl.text.trim()),
      ),
    );
  }

  Future<void> _perguntarSalvarCredenciais(String email, String senha) async {
    final credenciaisSalvas = await carregarCredenciais();
    if (credenciaisSalvas?.email == email) return;

    if (!mounted) return;
    final salvar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: AppColors.accent, size: 20),
            SizedBox(width: 8),
            Text(
              'Salvar acesso',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
            ),
          ],
        ),
        content: const Text(
          'Deseja salvar o e-mail e a senha neste dispositivo para facilitar o próximo acesso?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Não',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Salvar',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (salvar == true) await salvarCredenciais(email, senha);
  }

  @override
  Widget build(BuildContext context) {
    final carregando = context.watch<AccountService>().carregando;
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Column(
        children: [
          // Header com gradiente
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(gradient: AppColors.heroGradient),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 32,
              bottom: 32,
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
                  'Administração',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pizza Calculator',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.58),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Formulário
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration('E-mail', Icons.email),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Campo obrigatório';
                        if (!v.contains('@')) return 'E-mail inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _senhaCtrl,
                      obscureText: !_verSenha,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration(
                        'Senha',
                        Icons.lock,
                        sufixo: IconButton(
                          icon: Icon(
                            _verSenha
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          onPressed:
                              () => setState(() => _verSenha = !_verSenha),
                        ),
                      ),
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? 'Campo obrigatório'
                                  : null,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _abrirEsqueciSenha,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 0),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Esqueci minha senha',
                          style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: carregando ? null : _entrar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.barTop,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            carregando
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Entrar',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                    if (_mostrarBiometria) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () => _entrarComBiometria(
                            _emailCtrl.text.trim(),
                            _senhaCtrl.text,
                          ),
                          icon: const Icon(Icons.fingerprint, size: 22),
                          label: const Text('Entrar com biometria'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.accent,
                            side: const BorderSide(color: AppColors.accent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Não tem conta?',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CadastroScreen(),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Criar conta',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => context.go('/'),
                      child: const Text(
                        'Voltar ao Menu',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    Widget? sufixo,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.05,
      ),
      prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18),
      suffixIcon: sufixo,
      filled: true,
      fillColor: AppColors.inputBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.deleteFg, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.deleteFg, width: 1.5),
      ),
    );
  }
}
