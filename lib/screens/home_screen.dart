import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart'; // Importamos el dashboard para poder navegar a él

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Lógica centralizada para cerrar sesión
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Inicio - Api-san', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white), // Hace que el ícono de las 3 rayitas sea blanco
      ),
      
      // --- EL MENÚ LATERAL (DRAWER) ---
      drawer: Drawer(
        child: Column(
          children: [
            // Encabezado del menú con los datos de la administradora
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.green[700]),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.green),
              ),
              accountName: const Text('Anabel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              accountEmail: const Text('Administradora de Sanes'),
            ),
            
            // Opciones del Menú
            ListTile(
              leading: const Icon(Icons.home, color: Colors.green),
              title: const Text('Inicio', style: TextStyle(fontSize: 16)),
              onTap: () => Navigator.pop(context), // Solo cierra el menú porque ya estamos aquí
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined, color: Colors.blue),
              title: const Text('Dashboard Financiero', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context); // Cierra el menú lateral
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DashboardScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Colors.orange),
              title: const Text('Gestión de Clientes', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                print('Ir a clientes');
              },
            ),
            
            const Spacer(), // Empuja todo lo que esté abajo hacia el final de la pantalla
            const Divider(),
            
            // Botón de Cerrar Sesión al final del menú
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () => _cerrarSesion(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      // --- CUERPO DE LA PANTALLA OPERATIVA ---
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¡Hola, Anabel!',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Tareas y pendientes para hoy:',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // Tarjeta de Alerta del Día
            Card(
              color: Colors.amber[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.amber[300]!, width: 1),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.wb_sunny_outlined, color: Colors.amber, size: 30),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Recordatorio de Cobros', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 4),
                          Text('Tienes cobros pendientes quincenales que vencen hoy.', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            const Text(
              'Tus Sanes Activos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // Lista simulada de Sanes Operativos
            Expanded(
              child: ListView(
                children: [
                  _crearTarjetaSan('San Diario - Mercado', 'Progreso: 12/20 días', 0.6, Colors.green),
                  _crearTarjetaSan('San Quincenal - Personal', 'Progreso: 3/10 quincenas', 0.3, Colors.blue),
                  _crearTarjetaSan('San Semanal - Amigas', 'Progreso: 8/12 semanas', 0.66, Colors.purple),
                ],
              ),
            ),
          ],
        ),
      ),

      // --- BOTÓN FLOTANTE PARA ACCIONES RÁPIDAS ---
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        onPressed: () {
          print('Registrar un nuevo pago rápido');
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  // Widget auxiliar para crear las barras de progreso de los Sanes
  Widget _crearTarjetaSan(String titulo, String subtitulo, double progreso, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 5),
            Text(subtitulo, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progreso,
              backgroundColor: Colors.grey[200],
              color: color,
              minHeight: 8,
              borderRadius: BorderRadius.circular(5),
            ),
          ],
        ),
      ),
    );
  }
}