import 'package:flutter/material.dart';
import '../services/api_client.dart'; // Importa tu servicio de API
import '../models/usuario_respuesta_model.dart'; // Importa el modelo

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instanciamos nuestro cliente de API
    final ApiClient apiService = ApiClient();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey[800],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      // Usamos FutureBuilder para manejar la petición asíncrona
      body: FutureBuilder<UsuarioRespuestaModel>(
        future: apiService.obtenerPerfilUsuario(), // La petición que va a ejecutar
        builder: (context, snapshot) {
          
          // 1. Si está cargando, mostramos un indicador de progreso circular
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          // 2. Si ocurre un error (servidor caído, sin internet, etc.)
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'No se pudo cargar el perfil.\nInténtalo más tarde.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[600], fontSize: 16),
              ),
            );
          }

          // 3. Cuando los datos llegan con éxito
          if (snapshot.hasData) {
            // Extraemos el usuario del "snapshot"
            final usuario = snapshot.data!;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // --- AVATAR Y DATOS DINÁMICOS ---
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      // ¡AQUÍ COLOCAMOS EL NOMBRE REAL!
                      Text(
                        usuario.nombreCompleto, 
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      // ¡AQUÍ COLOCAMOS EL CORREO REAL!
                      Text(
                        usuario.correo, 
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
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
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            );
          }

          // Fallback por defecto si algo extraño ocurre
          return const Center(child: Text('No hay datos disponibles'));
        },
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    Widget? trailing,
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