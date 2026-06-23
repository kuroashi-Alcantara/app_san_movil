import 'package:flutter/material.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // Un color oscuro (pizarra/azul marino) para dar un tono de contabilidad
      appBar: AppBar(
        title: const Text('Finanzas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E293B), 
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
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
          // Tarjeta principal de balance
          _buildBalanceCard(),
          
          const SizedBox(height: 25),
          const Text('Últimos Movimientos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 15),
          
          // Lista de transacciones
          _buildTransactionTile(
            title: 'Pago Recibido',
            subtitle: 'De Carlos (San Navideño)',
            amount: '+ RD\$ 500',
            isIncome: true,
          ),
          _buildTransactionTile(
            title: 'Entrega de Turno',
            subtitle: 'A María (San Semanal)',
            amount: '- RD\$ 4,500',
            isIncome: false,
          ),
          _buildTransactionTile(
            title: 'Pago Recibido',
            subtitle: 'De José (San Navideño)',
            amount: '+ RD\$ 500',
            isIncome: true,
          ),
        ],
      ),
    );
  }

  // Widget para la tarjeta del capital en custodia
  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[700]!, Colors.green[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Capital en Custodia', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('RD\$ 19,500.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.white.withOpacity(0.8), size: 16),
              const SizedBox(width: 6),
              Text('De las 3 salas que administras', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  // Widget reutilizable para los items de la lista de movimientos
  Widget _buildTransactionTile({
    required String title, 
    required String subtitle, 
    required String amount, 
    required bool isIncome
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // Una pequeña línea de color a la izquierda para identificar rápido la entrada/salida
        side: BorderSide(color: isIncome ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5), width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isIncome ? Colors.green[50] : Colors.red[50],
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        trailing: Text(
          amount,
          style: TextStyle(
            color: isIncome ? Colors.green[700] : Colors.red[700],
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}