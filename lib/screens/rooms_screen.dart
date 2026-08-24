import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../models/sala_respuesta_model.dart';
import 'create_room_screen.dart'; 
import 'room_detail_screen.dart';
//  importar el archivo donde guardaste el SalaRespuestaModel
// import '../models/sala_model.dart'; 

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});
  

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

// El SingleTickerProviderStateMixin es vital para que las animaciones del TabBar funcionen
class _RoomsScreenState extends State<RoomsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiClient _api = ApiClient();
  bool _mostrarCanceladas = false;

  @override
  void initState() {
    super.initState();
    // Inicializamos el controlador para 2 pestañas
    _tabController = TabController(length: 2, vsync: this);
    
    // Le agregamos un "oído" para que cada vez que el usuario cambie de pestaña, 
    // la pantalla se redibuje y el botón flotante cambie.
    _tabController.addListener(() {
      setState(() {}); 
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

/* Funciones */
  // --- LÓGICA PARA UNIRSE A UNA SALA (Pestaña Participo) ---
  void _mostrarDialogoUnirse() {
    final codigoController = TextEditingController();
    bool cargando = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Text('Unirse a una Sala', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Ingresa el código de invitación que te proporcionó el administrador:'),
                  const SizedBox(height: 15),
                  TextField(
                    controller: codigoController,
                    decoration: const InputDecoration(
                      labelText: 'Código de Sala (Id)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.vpn_key),
                    ),
                  ),
                ],
              ),
              actions: [
                if (!cargando)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                  ),
                cargando
                    ? const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                        onPressed: () async {
                          if (codigoController.text.trim().isEmpty) return;
                          
                          setStateDialog(() => cargando = true);
                          final res = await _api.unirseASala(codigoController.text.trim());
                          setStateDialog(() => cargando = false);

                          if (mounted) {
                            Navigator.pop(context); // Cierra el diálogo
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(res['mensaje'].toString()),
                              backgroundColor: res['success'] == true ? Colors.green : Colors.red,
                            ));
                            
                            // Si se unió con éxito, recargamos la pantalla entera
                            if (res['success'] == true) {
                              setState(() {}); 
                            }
                          }
                        },
                        child: const Text('Unirme', style: TextStyle(color: Colors.white)),
                      ),
              ],
            );
          }
        );
      }
    );
  }

  //* Fin Funciones *//

  // --- AYUDANTES VISUALES ---
  String _obtenerFrecuencia(int valor) {
    switch (valor) {
      case 1: return 'Semanal';
      case 2: return 'Quincenal';
      case 3: return 'Mensual';
      default: return 'Desconocida';
    }
  }

  // --- AYUDANTES VISUALES PARA EL ESTADO ---
  Map<String, dynamic> _obtenerEstiloEstado(int estado) {
    switch (estado) {
      case 1:
        return {'texto': 'Reclutamiento', 'fondo': Colors.orange[100], 'letra': Colors.orange[800]};
      case 2:
        return {'texto': 'En Curso', 'fondo': Colors.green[100], 'letra': Colors.green[800]};
      case 3:
        return {'texto': 'Finalizada', 'fondo': Colors.blue[100], 'letra': Colors.blue[800]};
      case 4:
        return {'texto': 'Cancelada', 'fondo': Colors.red[100], 'letra': Colors.red[800]};
      default:
        return {'texto': 'Desconocido', 'fondo': Colors.grey[300], 'letra': Colors.grey[800]};
    }
  }

  // --- CONSTRUCTOR DE LAS LISTAS (Reutilizable para ambas pestañas) ---
  Widget _buildListaSalas(Future<List<dynamic>> futureMetodo, bool esAdmin) {
    return FutureBuilder<List<dynamic>>(
      future: futureMetodo,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error al cargar las salas: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No hay salas para mostrar.', style: TextStyle(fontSize: 16, color: Colors.grey)),
          );
        }

        final salas = snapshot.data!;
        
        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: salas.length,
          itemBuilder: (context, index) {
            final sala = salas[index]; // Aquí usas tu SalaRespuestaModel
            
            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(15),
                leading: CircleAvatar(
                  backgroundColor: Colors.green[100],
                  child: Icon(Icons.groups, color: Colors.green[800]),
                ),
                title: Text(
                  sala.nombreSala, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text('Cuota: \$${sala.montoCuota} - ${_obtenerFrecuencia(sala.frecuencia)}'),
                    Text('Participantes: ${sala.cantidadParticipantes}'),
                  ],
                ),
               trailing: Builder(
                  builder: (context) {
                    // 👇 1. Verificamos si el usuario está PENDIENTE (0) en esta sala
                    if (sala.miEstadoParticipacion == 0) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange[300]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time, size: 14, color: Colors.orange[800]),
                            const SizedBox(width: 4),
                            Text(
                              'Pendiente',
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 12
                              )
                            ),
                          ],
                        ),
                      );
                    }

                    // 👇 2. Si es ADMIN o está ACTIVO (1), mostramos el estado normal de la sala
                    final estilo = _obtenerEstiloEstado(sala.estado); 
                    
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: estilo['fondo'],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        estilo['texto'], 
                        style: TextStyle(
                          color: estilo['letra'],
                          fontWeight: FontWeight.bold,
                          fontSize: 12
                        )
                      ),
                    );
                  }
                ),
              onTap: () async {
                  // 👇 1. Bloqueamos el acceso si la solicitud está pendiente
                  if (sala.miEstadoParticipacion == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tu solicitud aún está en revisión por el administrador.'),
                        backgroundColor: Colors.orange,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return; // Salimos de la función sin navegar a detalles
                  }

                  // 2. Si no está pendiente, navegamos normalmente
                  final bool? necesitaActualizar = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoomDetailScreen(
                        roomId: sala.id.toString(),
                        esAdministrador: esAdmin,
                      ),
                    ),
                  );

                  // 3. Si la pantalla de detalles devolvió 'true', recargamos la lista
                  if (necesitaActualizar == true) {
                    setState(() {});
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Salas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        // 👇 AGREGAMOS EL SWITCH DEL HISTORIAL AQUÍ
        actions: [
          Row(
            children: [
              const Text(
                'Mostrar canceladas',
                style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: _mostrarCanceladas,
                activeColor: Colors.red.shade300,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.green.shade900,
                onChanged: (bool value) {
                  setState(() {
                    _mostrarCanceladas = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        // 👆 FIN DEL SWITCH
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.green[200],
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Administro', icon: Icon(Icons.manage_accounts)),
            Tab(text: 'Participo', icon: Icon(Icons.group)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 👇 Pestaña 1: Pasamos la variable a la API de administradas
          _buildListaSalas(_api.obtenerSalasAdministradas(incluirCanceladas: _mostrarCanceladas), true),
          
          // 👇 Pestaña 2: Pasamos la variable a la API de participadas
          _buildListaSalas(_api.obtenerSalasParticipadas(incluirCanceladas: _mostrarCanceladas), false),
        ],
      ),
      
      // EL FAB DINÁMICO: Cambia según la pestaña activa
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green[700],
        onPressed: ()  async {
          if (_tabController.index == 0) {
            // Navegamos a CreateRoomScreen y esperamos el resultado
            final result = await Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const CreateRoomScreen())
            );
            
            // Si el resultado es 'true', significa que se creó un San con éxito.
            if (result == true) {
              setState(() {}); 
            }
          } else {
            // Acción para Pestaña "Participo": Abrir modal para ingresar código
            _mostrarDialogoUnirse();
          }
        },
        icon: Icon(_tabController.index == 0 ? Icons.add : Icons.person_add, color: Colors.white),
        label: Text(
          _tabController.index == 0 ? 'Crear Sala' : 'Unirme', 
          style: const TextStyle(color: Colors.white)
        ),
      ),
    );
  }
}