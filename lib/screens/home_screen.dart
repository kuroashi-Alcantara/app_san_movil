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
  
  // --- 1. VARIABLES PARA EL USUARIO ---
  final _storage = const FlutterSecureStorage();
  String _nombreUsuario = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario(); // Disparamos la búsqueda al abrir la pantalla
  }

  // --- 2. FUNCIÓN QUE LEE LA BÓVEDA ---
  Future<void> _cargarDatosUsuario() async {
    final nombre = await _storage.read(key: 'nombre_usuario');
    if (mounted) {
      setState(() {
        _nombreUsuario = nombre ?? 'Usuario';
      });
    }
  }

  // 3. Convertimos esto en un "getter" (get) para poder pasarle la variable a _HomeContent
  List<Widget> get _pages => [
        _HomeContent(nombreUsuario: _nombreUsuario), // Pasamos el nombre aquí
        const RoomsScreen(),
        const FinanceScreen(), 
        const ContactsScreen(), 
      ];

  Future<void> _cerrarSesion(BuildContext context) async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'token'); // Usar 'token' si así lo guardaste en el login
    await storage.delete(key: 'nombre_usuario');
    await storage.delete(key: 'correo_usuario');
    
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
      
      // EL DRAWER LIMPIO (SOLO GESTIÓN Y AUDITORÍA)
      drawer: _buildDrawer(context),

      body: _pages[_currentIndex],

      // BARRA INFERIOR DE 4 OPCIONES
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed, 
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey[600],
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_carousel),
            label: 'Salas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Movimientos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Contactos'),
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
      child: Column(
        children: [
          // HEADER CLICKEABLE (PERFIL)
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.green[700]),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.green),
              ),
              // --- 4. ACTUALIZAMOS EL TEXTO DEL MENÚ LATERAL ---
              accountName: Text(
                _nombreUsuario,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: const Text('Toca para ver tu perfil'),
              margin: EdgeInsets.zero,
            ),
          ),

          // --- OPCIONES DE GESTIÓN ---
          ListTile(
            leading: const Icon(Icons.analytics_outlined, color: Colors.blue),
            title: const Text('Dashboard', style: TextStyle(fontSize: 16)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calculate, color: Colors.teal),
            title: const Text(
              'Calculadora de Sanes',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              print('Ir a Calculadora'); 
            },
          ),
          ListTile(
            leading: const Icon(Icons.archive, color: Colors.brown),
            title: const Text(
              'Sanes Archivados',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              print('Ir a Archivados'); 
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.purple),
            title: const Text(
              'Historial de Actividad',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              print('Ir a Historial');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.orange),
            title: const Text(
              'Soporte y Ayuda',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              print('Ir a Soporte');
            },
          ),

          // --- EMPUJE HACIA ABAJO ---
          const Spacer(),
          const Divider(height: 1),

          // --- CERRAR SESIÓN (AL FONDO) ---
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () => _cerrarSesion(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// 5. DISEÑO ORIGINAL 
class _HomeContent extends StatelessWidget {
  // --- 5. RECIBIMOS LA VARIABLE DESDE AFUERA ---
  final String nombreUsuario;

  const _HomeContent({required this.nombreUsuario, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Inicio - SanRD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(), 
        ),
      ),
      body: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 6. QUITAMOS EL CONST Y USAMOS LA VARIABLE ---
          Text(
            '¡Hola, $nombreUsuario!',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
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
                        Text(
                          'Recordatorio de Cobros',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tienes cobros pendientes quincenales que vencen hoy.',
                          style: TextStyle(fontSize: 14),
                        ),
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
                _crearTarjetaSan(
                  'San Diario - Mercado',
                  'Progreso: 12/20 días',
                  0.6,
                  Colors.green,
                ),
                _crearTarjetaSan(
                  'San Quincenal - Personal',
                  'Progreso: 3/10 quincenas',
                  0.3,
                  Colors.blue,
                ),
                _crearTarjetaSan(
                  'San Semanal - Amigas',
                  'Progreso: 8/12 semanas',
                  0.66,
                  Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
      )
    );
  }

  // Widget auxiliar para crear las barras de progreso
  Widget _crearTarjetaSan(
    String titulo,
    String subtitulo,
    double progreso,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              subtitulo,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
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
