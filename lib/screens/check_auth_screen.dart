import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class CheckAuthScreen extends StatefulWidget {
  const CheckAuthScreen({super.key});

  @override
  State<CheckAuthScreen> createState() => _CheckAuthScreenState();
}

class _CheckAuthScreenState extends State<CheckAuthScreen> {
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _revisarToken();
  }

  Future<void> _revisarToken() async {
    // Leemos la bóveda buscando la llave 'auth_token'
    String? token = await _storage.read(key: 'auth_token');

    // Esperamos un segundito extra solo para que se vea la animación de carga (opcional)
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (token != null) {
      // ¡Sí hay token! El usuario ya estaba logueado. Salto al Dashboard.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      // Bóveda vacía. Salto al Login.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // Un circulito de carga mientras revisamos la memoria
        child: CircularProgressIndicator(color: Colors.green),
      ),
    );
  }
}