import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_client.dart'; // Ajusta la ruta según la ubicación de tu ApiClient
// Importa tu modelo si lo tienes en un archivo separado, ej: import '../models/usuario_respuesta_model.dart';
import 'login_screen.dart';
import 'editar_perfil_screen.dart';
import '../models/usuario_respuesta_model.dart'; // Asegúrate de tener este modelo definido
// Asegúrate de tener este modelo definido

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiClient _apiClient = ApiClient();
  late Future<UsuarioRespuestaModel> _usuarioFuture;
  
  // Variable temporal para darle vida al switch del Modo Oscuro
  bool _modoOscuro = false; 

  @override
  void initState() {
    super.initState();
    // 1. Iniciamos la petición al backend en cuanto se abre la pantalla
    _usuarioFuture = _apiClient.obtenerPerfilUsuario();
  }

  // 2. Función dedicada para cerrar sesión
  void _cerrarSesion() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'token'); // Borramos la llave principal
    await storage.delete(key: 'nombre_usuario'); // Limpiamos los datos del inicio
    await storage.delete(key: 'correo_usuario');
    
    if (mounted) {
      // Navegamos al login y destruimos todo el historial de navegación
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
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<UsuarioRespuestaModel>(
        future: _usuarioFuture,
        builder: (context, snapshot) {
          // Mientras viaja por internet, mostramos el círculo de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          } 
          // Si algo falla en la red
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } 
          // Si el backend no devolvió datos por alguna razón
          else if (!snapshot.hasData) {
            return const Center(child: Text('No se pudo cargar el perfil'));
          }

          // 3. ¡Extraemos al usuario con los datos reales!
          final usuario = snapshot.data!;

          return Column(
            children: [
              // --- SECCIÓN 1: CABECERA VERDE CON DATOS ---
              Container(
                width: double.infinity,
                color: Colors.green[700],
                padding: const EdgeInsets.only(bottom: 30, top: 10),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      // El ícono azul tal cual tienes en el diseño
                      child: Icon(Icons.person, size: 60, color: Colors.blue), 
                    ),
                    const SizedBox(height: 15),
                    Text(
                      usuario.nombreCompleto,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      usuario.correo,
                      style: TextStyle(fontSize: 16, color: Colors.green[100]),
                    ),
                  ],
                ),
              ),
              
              // --- SECCIÓN 2: TARJETA DE CONFIGURACIÓN ---
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      'Configuración General',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        children: [
                          
                          // Botón: Editar Perfil
                          ListTile(
                            leading: const Icon(Icons.edit_outlined, color: Colors.blue),
                            title: const Text('Editar Perfil', style: TextStyle(fontWeight: FontWeight.w500)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () async {
                              // Navegamos hacia la nueva pantalla pasándole los datos en tiempo real
                              final huboCambios = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditarPerfilScreen(
                                    nombreInicial: usuario.nombreCompleto,
                                    telefonoInicial: usuario.telefono, 
                                  ),
                                ),
                              );

                              // Si regresamos con un "true", forzamos a recargar los datos
                              if (huboCambios == true) {
                                setState(() {
                                  _usuarioFuture = _apiClient.obtenerPerfilUsuario();
                                });
                              }
                            },
                          ),
                          const Divider(height: 1, indent: 50, endIndent: 20),
                          
                          // Botón: Notificaciones (Inactivo por ahora)
                          ListTile(
                            leading: const Icon(Icons.notifications_none, color: Colors.orange),
                            title: const Text('Notificaciones', style: TextStyle(fontWeight: FontWeight.w500)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Configuración de notificaciones próximamente')),
                              );
                            },
                          ),
                          const Divider(height: 1, indent: 50, endIndent: 20),
                          
                          // Botón: Modo Oscuro (Switch interactivo)
                          SwitchListTile(
                            secondary: const Icon(Icons.dark_mode_outlined, color: Colors.purple),
                            title: const Text('Modo Oscuro', style: TextStyle(fontWeight: FontWeight.w500)),
                            value: _modoOscuro,
                            activeColor: Colors.green[700],
                            onChanged: (bool value) {
                              setState(() {
                                _modoOscuro = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- SECCIÓN 3: PIE DE PÁGINA (CERRAR SESIÓN) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, 
                      foregroundColor: Colors.red, // Letras e ícono rojos
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(color: Colors.red, width: 1.5), // Borde marcado rojo
                      ),
                    ),
                    onPressed: _cerrarSesion,
                    icon: const Icon(Icons.logout, size: 24),
                    label: const Text(
                      'Cerrar Sesión', 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}