import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'rooms_screen.dart';
import 'finance_screen.dart';
import 'profile_screen.dart';
import 'contacts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Lista de pantallas para la barra inferior
  final List<Widget> _pages = [
    const _HomeContent(), // Tu contenido original de inicio
    const RoomsScreen(),
    const FinanceScreen(),
  ];

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
        title: const Text('Api-san', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(context),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.view_carousel), label: 'Salas'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Finanzas'),
        ],
      ),
      floatingActionButton: _currentIndex == 0 
          ? FloatingActionButton(
              backgroundColor: Colors.green[700],
              onPressed: () => print('Acción: Registrar pago rápido'),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ) 
          : null,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.green[700]),
            currentAccountPicture: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: Colors.green)),
            accountName: const Text('Anabel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: const Text('Administradora de Sanes'),
          ),
          ListTile(leading: const Icon(Icons.analytics_outlined, color: Colors.blue), title: const Text('Dashboard'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardScreen())); }),
          ListTile(leading: const Icon(Icons.group, color: Colors.orange), title: const Text('Gestión de Clientes'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactsScreen())); }),
          ListTile(leading: const Icon(Icons.settings, color: Colors.grey), title: const Text('Configuración'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())); }),
          const Divider(),
          ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), onTap: () => _cerrarSesion(context)),
        ],
      ),
    );
  }
}

// Extraje tu contenido original a un widget separado para limpiar el HomeScreen
class _HomeContent extends StatelessWidget {
  const _HomeContent();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('¡Hola, Anabel!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          // ... aquí va el resto de tu UI original (Tarjetas y lista de Sanes)
        ],
      ),
    );
  }
}