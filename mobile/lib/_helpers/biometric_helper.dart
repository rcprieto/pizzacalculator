import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyBiometria = 'biometria_ativa';

Future<bool> biometriaDisponivel() async {
  final auth = LocalAuthentication();
  try {
    final suportado = await auth.isDeviceSupported();
    if (!suportado) return false;
    final tipos = await auth.getAvailableBiometrics();
    return tipos.isNotEmpty;
  } catch (_) {
    return false;
  }
}

/// Retorna null se autenticado com sucesso, ou a mensagem de erro.
Future<String?> autenticarBiometria() async {
  final auth = LocalAuthentication();
  try {
    final autenticado = await auth.authenticate(
      localizedReason: 'Use sua biometria para entrar no Pizza Calculator',
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: false,
      ),
    );
    return autenticado ? null : 'Biometria não reconhecida.';
  } catch (e) {
    return 'Erro na biometria: $e';
  }
}

Future<bool?> getBiometriaAtiva() async {
  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey(_keyBiometria)) return null;
  return prefs.getBool(_keyBiometria);
}

Future<void> setBiometriaAtiva(bool valor) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_keyBiometria, valor);
}
