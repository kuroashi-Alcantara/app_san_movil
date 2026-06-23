import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey[800], // Un color neutro y elegante
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- AVATAR Y DATOS PRINCIPALES ---
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text('Anabel', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('anabel@ejemplo.com', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              ],
            ),
          ),
          
          const SizedBox(height: 30),

          // --- SECCIÓN DE CONFIGURACIÓN ---
          const Text('Configuración General', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 10),

          _buildSettingsTile(
            icon: Icons.edit,
            title: 'Editar Perfil',
            color: Colors.blue,
            onTap: () => print('Acción: Abrir edición de perfil'),
          ),
          _buildSettingsTile(
            icon: Icons.notifications,
            title: 'Notificaciones',
            color: Colors.orange,
            onTap: () => print('Acción: Configurar notificaciones'),
          ),
          _buildSettingsTile(
            icon: Icons.dark_mode,
            title: 'Modo Oscuro',
            color: Colors.purple,
            // Agregamos un switch visual para representar el cambio de tema
            trailing: Switch(
              value: false,
              onChanged: (value) => print('Acción: Cambiar a modo oscuro'),
            ),
            onTap: () {},
          ),

          const SizedBox(height: 30),

          // --- BOTÓN DE CERRAR SESIÓN ---
          ElevatedButton.icon(
            onPressed: () {
              print('Acción: Limpiar token de sesión y salir');
              // Más adelante, aquí haremos: Navigator.pushReplacement(context, LoginScreen)
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600], // Rojo para indicar una acción destructiva/de salida
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Molde visual para reutilizar las opciones de configuración
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    Widget? trailing, // El Switch es opcional, si no se pasa, usa una flecha
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}