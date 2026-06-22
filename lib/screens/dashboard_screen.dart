import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_screen.dart'; 

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio - Api-san'),
        backgroundColor: Colors.blueAccent,
        actions: [
          // Botón de Cerrar Sesión en la esquina superior derecha
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              // 1. Abrimos la bóveda
              const storage = FlutterSecureStorage();
              
              // 2. ¡Destruimos el token!
              await storage.delete(key: 'auth_token');
              
              // 3. Regresamos al Login destruyendo las pantallas anteriores
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false, // Este 'false' es clave: elimina el historial
                );
              }
            },
          )
        ],
      ),
      body: const Center(
        child: Text(
          '¡Bienvenida, Anabel!\nLogin Exitoso.',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}