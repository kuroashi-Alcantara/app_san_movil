import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_screen.dart'; 

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Método para cerrar sesión (separado para mantener el diseño limpio)
  Future<void> _cerrarSesion(BuildContext context) async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'auth_token');
    
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Un fondo ligeramente gris para que resalten las tarjetas blancas
      appBar: AppBar(
        title: const Text('Gestor de San', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700], // Verde haciendo juego con tu Login
        elevation: 0, // Quitamos la sombra para un diseño más plano y moderno
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar Sesión',
            onPressed: () => _cerrarSesion(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BLOQUE 1: Bienvenida ---
            const Text(
              '¡Hola, Anabel!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              'Este es el resumen de tus operaciones de hoy.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 25),

            // --- BLOQUE 2: Tarjeta de Resumen ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[600]!, Colors.green[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Recaudado', 
                    style: TextStyle(color: Colors.white70, fontSize: 16)
                  ),
                  SizedBox(height: 8),
                  Text(
                    'RD\$ 45,500.00', // Dato quemado por ahora, luego vendrá de tu API
                    style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),

            // --- BLOQUE 3: Cuadrícula de Acciones Rápidas ---
            const Text(
              'Acciones Rápidas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            
            // Usamos Expanded para que la cuadrícula ocupe el resto de la pantalla disponible
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // 2 columnas
                crossAxisSpacing: 15, // Espacio horizontal entre tarjetas
                mainAxisSpacing: 15,  // Espacio vertical entre tarjetas
                children: [
                  _crearBotonMenu(Icons.group, 'Clientes', Colors.blue),
                  _crearBotonMenu(Icons.account_balance_wallet, 'Mis Sanes', Colors.orange),
                  _crearBotonMenu(Icons.payments, 'Pagos', Colors.purple),
                  _crearBotonMenu(Icons.history, 'Historial', Colors.teal),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET REUTILIZABLE ---
  // Creamos este molde para no escribir el mismo código 4 veces para cada botón
  Widget _crearBotonMenu(IconData icono, String titulo, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell( // InkWell le da el efecto de "onda" al hacer clic
        onTap: () {
          print('El usuario quiere ir a la pantalla de: $titulo');
          // Aquí programaremos la navegación más adelante
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              radius: 35,
              child: Icon(icono, size: 35, color: color),
            ),
            const SizedBox(height: 15),
            Text(
              titulo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}