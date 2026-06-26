import 'package:flutter/material.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // 1. APPBAR UNIFICADO CON EL RESTO DE LA APP
      appBar: AppBar(
        title: const Text('Movimientos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700], // Mismo verde para mantener armonía visual
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(), // Abre el menú lateral
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => print('Acción: Filtrar movimientos'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 2. NUEVA TARJETA ENFOCADA EN VOUCHERS / COMPROBANTES
          _buildVoucherSummaryCard(),
          
          const SizedBox(height: 25),
          Text(
            'Historial de Comprobantes', 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])
          ),
          const SizedBox(height: 15),
          
          // 3. LISTA DE MOVIMIENTOS CON ESTATUS DE VOUCHERS
          _buildMovementTile(
            title: 'Comprobante Subido',
            subtitle: 'San Navideño - Quincena 4',
            amount: 'RD\$ 1,500',
            status: 'Aprobado',
            statusColor: Colors.green,
            icon: Icons.check_circle,
          ),
          _buildMovementTile(
            title: 'Comprobante Subido',
            subtitle: 'San Semanal Familia',
            amount: 'RD\$ 500',
            status: 'Pendiente',
            statusColor: Colors.orange,
            icon: Icons.access_time_filled,
          ),
          _buildMovementTile(
            title: 'Entrega de Turno (Cobro)',
            subtitle: 'San Navideño - Turno #2',
            amount: 'RD\$ 15,000',
            status: 'Completado',
            statusColor: Colors.blue,
            icon: Icons.account_balance_wallet,
          ),
          _buildMovementTile(
            title: 'Comprobante Subido',
            subtitle: 'San Semanal Amigas',
            amount: 'RD\$ 1,000',
            status: 'Rechazado (Ilegible)',
            statusColor: Colors.red,
            icon: Icons.cancel,
          ),
        ],
      ),
    );
  }

  // Widget para la tarjeta de resumen de comprobantes
  Widget _buildVoucherSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueGrey[700]!, Colors.blueGrey[900]!], // Un tono elegante para diferenciarlo del verde de inicio
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.blueGrey.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estado de tus pagos', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryColumn('Aprobados', '12', Colors.greenAccent),
              _buildSummaryColumn('Pendientes', '1', Colors.orangeAccent),
              _buildSummaryColumn('Rechazados', '0', Colors.redAccent),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.receipt_long, color: Colors.white.withOpacity(0.8), size: 16),
              const SizedBox(width: 6),
              Text('Conserva los recibos físicos por seguridad', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  // Pequeño widget auxiliar para la tarjeta principal
  Widget _buildSummaryColumn(String label, String count, Color color) {
    return Column(
      children: [
        Text(count, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  // Widget reutilizable para los items de la lista
  Widget _buildMovementTile({
    required String title, 
    required String subtitle, 
    required String amount, 
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.5), width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(icon, color: statusColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 4),
            Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: Text(
          amount,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}