import 'package:flutter/material.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdminView = _tabController.index == 0;
    final Color themeColor = isAdminView ? Colors.green[700]! : Colors.blueGrey[700]!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Contactos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: themeColor,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.people_alt), text: 'PARTICIPANTES'),
            Tab(icon: Icon(Icons.import_contacts), text: 'DIRECTORIO'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildParticipantList(), // Solo gente de tus salas (cobros activos)
          _buildDirectoryList(),   // Tu agenda personal de confianza
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeColor,
        onPressed: () => print('Acción: Agregar contacto'),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildParticipantList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _ContactCard(name: 'María Gómez', subtitle: 'Atraso de RD\$ 500', isStatusOk: false),
        _ContactCard(name: 'Richard Osoria', subtitle: 'Al día', isStatusOk: true),
      ],
    );
  }

  Widget _buildDirectoryList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _ContactCard(name: 'Jonas (Amigo)', subtitle: 'Socio en San 1', isStatusOk: true),
        _ContactCard(name: 'Papá (Familia)', subtitle: 'Participante', isStatusOk: true),
      ],
    );
  }
}

// Widget auxiliar para mantener el código limpio y DRY (Don't Repeat Yourself)
class _ContactCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final bool isStatusOk;

  const _ContactCard({required this.name, required this.subtitle, required this.isStatusOk});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isStatusOk ? Colors.green[100] : Colors.red[100],
          child: Text(name[0], style: TextStyle(color: isStatusOk ? Colors.green[900] : Colors.red[900])),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: isStatusOk ? Colors.grey : Colors.red)),
        trailing: const Icon(Icons.chevron_right, size: 16),
      ),
    );
  }
}