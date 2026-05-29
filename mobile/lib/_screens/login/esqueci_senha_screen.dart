import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../_models/dtos.dart';
import '../../_services/account_service.dart';
import '../../_theme/app_colors.dart';

class EsqueciSenhaScreen extends StatefulWidget {
  final String emailInicial;
  const EsqueciSenhaScreen({super.key, this.emailInicial = ''});

  @override
  State<EsqueciSenhaScreen> createState() => _EsqueciSenhaScreenState();
}

class _EsqueciSenhaScreenState extends State<EsqueciSenhaScreen> {
  final _emailCtrl = TextEditingController();
  bool _enviando = false;
  bool _enviado = false;
  String _erro = '';

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = widget.emailInicial;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;
    setState(() { _enviando = true; _erro = ''; });
    final erro = await context.read<AccountService>().esqueciSenha(
      EsqueciSenhaDto(email: email),
    );
    if (!mounted) return;
    setState(() => _enviando = false);
    if (erro != null) {
      setState(() => _erro = erro);
    } else {
      setState(() => _enviado = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(gradient: AppColors.barGradient),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              bottom: 16,
              left: 4,
              right: 16,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Text(
                    'Recuperar acesso',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _enviado ? _buildSucesso() : _buildFormulario(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accentBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: AppColors.accent, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Informe seu e-mail e enviaremos uma nova senha temporária.',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            labelText: 'E-mail',
            labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            prefixIcon: const Icon(Icons.email_outlined,
                color: AppColors.textMuted, size: 18),
            filled: true,
            fillColor: AppColors.cardBg,
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
          ),
        ),
        if (_erro.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.deleteBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(_erro,
                style: const TextStyle(
                    color: AppColors.deleteFg, fontSize: 13)),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _enviando ? null : _enviar,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.barTop,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _enviando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Enviar nova senha',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildSucesso() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.mark_email_read_outlined,
            size: 64, color: AppColors.accent),
        const SizedBox(height: 20),
        const Text(
          'E-mail enviado!',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        const Text(
          'Se o e-mail estiver cadastrado, você receberá\numa nova senha em instantes.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 32),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Voltar ao login',
              style: TextStyle(color: AppColors.accent, fontSize: 15)),
        ),
      ],
    );
  }
}
