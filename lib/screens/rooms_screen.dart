import 'package:flutter/material.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    _tabController.addListener(() {
      setState(() {}); 
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = _tabController.index == 0;
    final Color themeColor = isAdmin ? Colors.green[700]! : Colors.blue[700]!;
    final IconData fabIcon = isAdmin ? Icons.add : Icons.search;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mis Salas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: themeColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 4,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.manage_accounts), text: 'ADMINISTRO'),
            Tab(icon: Icon(Icons.group), text: 'PARTICIPO'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAdminView(),
          _buildParticipantView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeColor,
        onPressed: () {
          if (isAdmin) {
            print('Acción: Crear nueva sala');
          } else {
            print('Acción: Buscar código de sala');
          }
        },
        child: Icon(fabIcon, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildAdminView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Text('Salas que tú gestionas:', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ),
        _createRoomCard(
          title: 'San Navideño 🎄',
          subtitle: 'Progreso: Quincena 4 de 10',
          extraData: 'Caja actual: RD\$ 15,000',
          progress: 0.4,
          borderColor: Colors.green,
        ),
        _createRoomCard(
          title: 'San Semanal Familia',
          subtitle: 'Progreso: Semana 2 de 5',
          extraData: 'Caja actual: RD\$ 4,500',
          progress: 0.4,
          borderColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildParticipantView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Text('Salas a las que fuiste invitado:', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ),
        _createRoomCard(
          title: 'San de la Oficina 🏢',
          subtitle: 'Administrador: Carlos Pérez',
          extraData: 'Mi Turno: #3 (15 de Julio)',
          progress: 0.7,
          borderColor: Colors.blue,
        ),
        _createRoomCard(
          title: 'San de Amigos',
          subtitle: 'Administrador: María Gómez',
          extraData: 'Mi Turno: #8 (Pendiente)',
          progress: 0.2,
          borderColor: Colors.blue,
        ),
      ],
    );
  }

  Widget _createRoomCard({
    required String title,
    required String subtitle,
    required String extraData,
    required double progress,
    required MaterialColor borderColor,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor[600]!, width: 1.5), 
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          print('Entrar al detalle de la sala: $title');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
              const SizedBox(height: 8),
              Text(subtitle, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
              const SizedBox(height: 12),
              Text(extraData, style: TextStyle(color: borderColor[700], fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 15),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                color: borderColor[500],
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}