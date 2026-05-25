import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../_models/dtos.dart';
import '../../../_services/account_service.dart';
import '../../../_theme/app_colors.dart';

class UsuarioListaScreen extends StatefulWidget {
  const UsuarioListaScreen({super.key});

  @override
  State<UsuarioListaScreen> createState() => _UsuarioListaScreenState();
}

class _UsuarioListaScreenState extends State<UsuarioListaScreen> {
  List<UsuarioDto> _usuarios = [];
  bool _carregando = false;
  bool _mostrarFormulario = false;
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    final lista = await context.read<AccountService>().listarUsuarios();
    if (mounted) setState(() { _usuarios = lista ?? []; _carregando = false; });
  }

  Future<void> _salvar() async {
    final email = _emailCtrl.text.trim();
    final senha = _senhaCtrl.text.trim();
    if (email.isEmpty || senha.isEmpty) return;
    setState(() => _salvando = true);
    final erro = await context.read<AccountService>().registrar(
      RegisterDto(email: email, password: senha),
    );
    if (!mounted) return;
    setState(() => _salvando = false);
    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: AppColors.deleteFg),
      );
    } else {
      _emailCtrl.clear();
      _senhaCtrl.clear();
      setState(() => _mostrarFormulario = false);
      await _carregar();
    }
  }

  Future<void> _confirmarDesativar(UsuarioDto usuario) async {
    final meuEmail = context.read<AccountService>().usuarioAtual?.email;
    if (usuario.email == meuEmail) return;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text('Desativar usuário',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        content: Text('Desativar "${usuario.email}"?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Desativar',
                style: TextStyle(color: AppColors.deleteFg)),
          ),
        ],
      ),
    );
    if (confirmar == true && mounted) {
      final erro = await context.read<AccountService>().excluirUsuario(usuario.id);
      if (mounted) {
        if (erro != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(erro), backgroundColor: AppColors.deleteFg),
          );
        } else {
          setState(() => _usuarios.removeWhere((u) => u.id == usuario.id));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.people,
                          color: AppColors.textMuted, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Usuários do sistema',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () =>
                    setState(() => _mostrarFormulario = !_mostrarFormulario),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.barGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _mostrarFormulario ? Icons.close : Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: AppColors.borderLight),
        // Formulário inline
        if (_mostrarFormulario) _buildFormulario(),
        // Lista
        Expanded(
          child: _carregando
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.accent))
              : _usuarios.isEmpty
                  ? const Center(
                      child: Text('Nenhum usuário encontrado',
                          style: TextStyle(color: AppColors.textMuted)))
                  : ListView.separated(
                      itemCount: _usuarios.length,
                      separatorBuilder: (_, _) =>
                          Container(height: 1, color: Colors.black.withValues(alpha: 0.04)),
                      itemBuilder: (context, index) {
                        final usuario = _usuarios[index];
                        final ehEu = usuario.email ==
                            context.read<AccountService>().usuarioAtual?.email;
                        return _UsuarioItem(
                          usuario: usuario,
                          ehEu: ehEu,
                          onDesativar: ehEu ? null : () => _confirmarDesativar(usuario),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFormulario() {
    return Container(
      color: AppColors.cardBg,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Novo Usuário',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8)),
          const SizedBox(height: 10),
          _campo(_emailCtrl, 'E-mail', TextInputType.emailAddress),
          const SizedBox(height: 8),
          _campo(_senhaCtrl, 'Senha', TextInputType.visiblePassword, obscure: true),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() => _mostrarFormulario = false),
                child: const Text('Cancelar',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _salvando ? null : _salvar,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: AppColors.barGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _salvando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Salvar',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                ),
              ),
            ],
          ),
          Container(height: 1, color: AppColors.borderLight),
        ],
      ),
    );
  }

  Widget _campo(TextEditingController ctrl, String hint, TextInputType tipo,
      {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: tipo,
      obscureText: obscure,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppColors.textMuted, fontSize: 14),
        filled: true,
        fillColor: AppColors.inputBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }
}

class _UsuarioItem extends StatelessWidget {
  final UsuarioDto usuario;
  final bool ehEu;
  final VoidCallback? onDesativar;

  const _UsuarioItem({
    required this.usuario,
    required this.ehEu,
    required this.onDesativar,
  });

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
            decoration: BoxDecoration(
              color: const Color(0xFFf0fff4),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.person,
                color: Color(0xFF27ae60), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usuario.email,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.iconGrupoBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        usuario.role,
                        style: const TextStyle(
                            color: AppColors.iconGrupoFg, fontSize: 11),
                      ),
                    ),
                    if (ehEu) ...[
                      const SizedBox(width: 6),
                      const Text('(você)',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (onDesativar != null)
            GestureDetector(
              onTap: onDesativar,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.deleteBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.person_off_outlined,
                    color: AppColors.deleteFg, size: 16),
              ),
            ),
        ],
      ),
    );
  }
}
