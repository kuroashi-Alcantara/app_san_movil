import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos el color de tu tema (verde)
    final Color themeColor = Colors.green[700] ?? Colors.green;

    // DefaultTabController nos ahorra usar un StatefulWidget
    return DefaultTabController(
      length: 2, // Número de pestañas
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Dashboard Financiero', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: themeColor,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Como Participante'),
              Tab(icon: Icon(Icons.admin_panel_settings), text: 'Como Administrador'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildParticipanteView(themeColor),
            _buildAdminView(themeColor),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // VISTA 1: ESTADÍSTICAS COMO PARTICIPANTE
  // ==========================================
  Widget _buildParticipanteView(Color themeColor) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Tarjeta de Reputación
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.amber[100],
              radius: 30,
              child: const Icon(Icons.workspace_premium, color: Colors.amber, size: 35),
            ),
            title: const Text('Nivel Oro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: const Text('100% de pagos a tiempo\n¡Excelente reputación!'),
          ),
        ),
        const SizedBox(height: 16),
        
        // Tarjeta de Ahorros
        _crearTarjetaEstadistica(
          titulo: 'Total Recibido (Ahorrado)',
          valor: 'RD\$ 50,000',
          icono: Icons.savings,
          colorIcono: themeColor,
        ),
        const SizedBox(height: 16),

        // Tarjeta de Compromisos
        _crearTarjetaEstadistica(
          titulo: 'Compromisos de este mes',
          valor: 'RD\$ 4,500',
          icono: Icons.calendar_month,
          colorIcono: Colors.orange,
        ),
      ],
    );
  }

  // ==========================================
  // VISTA 2: ESTADÍSTICAS COMO ADMINISTRADOR
  // ==========================================
  Widget _buildAdminView(Color themeColor) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Tarjeta de Capital Movido
        _crearTarjetaEstadistica(
          titulo: 'Capital Total Gestionado',
          valor: 'RD\$ 150,000',
          icono: Icons.account_balance,
          colorIcono: Colors.blue[700]!,
        ),
        const SizedBox(height: 16),

        // Fila con dos estadísticas pequeñas
        Row(
          children: [
            Expanded(
              child: _crearTarjetaEstadistica(
                titulo: 'Sanes Creados',
                valor: '12',
                icono: Icons.library_add_check,
                colorIcono: themeColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _crearTarjetaEstadistica(
                titulo: 'Participantes',
                valor: '45',
                icono: Icons.groups,
                colorIcono: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Sección de Ranking
        const Text(
          'Top Pagadores',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.looks_one, color: Colors.amber),
                title: const Text('Richard Osoria'),
                trailing: const Text('100% Puntual', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.looks_two, color: Colors.grey[400]),
                title: const Text('Jonas'),
                trailing: const Text('98% Puntual', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        )
      ],
    );
  }

  // ==========================================
  // WIDGET REUTILIZABLE PARA LAS TARJETAS
  // ==========================================
  Widget _crearTarjetaEstadistica({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color colorIcono,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorIcono.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icono, color: colorIcono, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(valor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}