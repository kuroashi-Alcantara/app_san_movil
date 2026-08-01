import 'package:flutter/material.dart';
import '/services/api_client.dart';
import 'package:flutter/services.dart';

class RoomDetailScreen extends StatefulWidget {
  final String roomId;
  final bool esAdministrador; // 👇 NUEVA VARIABLE AÑADIDA

  const RoomDetailScreen({
    Key? key, 
    required this.roomId,
    this.esAdministrador = false, // Por defecto falso por seguridad
  }) : super(key: key);

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  final ApiClient _apiClient = ApiClient();
  Map<String, dynamic>? _room;
  bool _isLoading = true;

  // Variables para la edición en línea del nombre
  bool _editandoNombre = false;
  late TextEditingController _nombreController;

  //Cuota
  bool _editandoCuota = false;
  late TextEditingController _cuotaController;

  //Frecuencia
  bool _editandoFrecuencia = false;
  int _frecuenciaSeleccionada = 3; // Empezamos en 3 (Mensual) por defecto

  //Cantidad Participantes
  bool _editandoLimite = false;
  late TextEditingController _limiteController;

  // Guardador
  bool _isGuardando = false; 

  bool _seHicieronCambios = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _cuotaController = TextEditingController();
    _limiteController = TextEditingController();
    _loadRoomDetails();
  }

  @override
  void dispose() {
    _nombreController.dispose(); 
    _cuotaController.dispose(); 
    _limiteController.dispose(); 
    super.dispose();
  }

  //*******FUNCIONES*******

  Future<void> _loadRoomDetails() async {
    setState(() => _isLoading = true);

    final data = await _apiClient.obtenerDetalleSala(widget.roomId);

    setState(() {
      _room = data;
      _nombreController.text = _room?['nombreSala'] ?? '';
      _cuotaController.text = _room?['montoCuota']?.toString() ?? '0';
      _limiteController.text = _room?['cantidadParticipantes']?.toString() ?? '0';
      _isLoading = false;
    });
  }

  Future<bool> _confirmarEdicionCritica(String campo) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Atención'),
          ],
        ),
        content: Text(
          'Estás a punto de modificar $campo. Esto altera las reglas principales del San.\n\n¿Estás seguro de que deseas habilitar la edición?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Sí, editar'),
          ),
        ],
      ),
    );

    return resultado ?? false; 
  }

 Future<void> _editarFechaInicio() async {
    String fechaActualStr = _room?['fechaInicio']?.toString() ?? '';
    
    DateTime ahora = DateTime.now();
    DateTime fechaInicial = ahora;
    
    if (fechaActualStr.isNotEmpty) {
      DateTime? fechaParseada = DateTime.tryParse(fechaActualStr);
      if (fechaParseada != null) {
        fechaInicial = fechaParseada;
      }
    }

    DateTime primeraFechaPermitida = ahora;
    if (fechaInicial.isBefore(ahora)) {
      primeraFechaPermitida = fechaInicial; 
    }

    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: primeraFechaPermitida, 
      lastDate: DateTime(ahora.year + 5),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        String mes = fechaSeleccionada.month.toString().padLeft(2, '0');
        String dia = fechaSeleccionada.day.toString().padLeft(2, '0');
        _room!['fechaInicio'] = "${fechaSeleccionada.year}-$mes-$dia";
      });
    }
  }

  Future<void> _guardarCambios() async {
    if (_room == null) return;

    setState(() {
      _isGuardando = true;
    });

    try {
      final apiClient = ApiClient(); 
      String salaId = _room!['id'].toString(); 

      final resultado = await apiClient.actualizarSala(salaId, _room!);

      if (!mounted) return;

      if (resultado['success'] == true) {
        _seHicieronCambios = true;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['mensaje']),
          backgroundColor: resultado['success'] ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error inesperado de conexión.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGuardando = false;
        });
      }
    }
  }

  void _mostrarDialogoInvitacion() {
    final String codigoSala = _room?['id']?.toString() ?? 'Código no disponible';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Invitar Participantes', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Copia este código y envíalo a las personas que quieres que se unan a este San:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: SelectableText(
                  codigoSala,
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold, 
                    letterSpacing: 1.5,
                    color: Colors.green[900]
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: codigoSala));
                Navigator.pop(context); 
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('¡Código copiado al portapapeles! Listo para pegar en WhatsApp.'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Copiar Código'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _aceptarSolicitud(String usuarioId) async {
    final String? salaId = _room?['id']?.toString();
    if (salaId == null) return;

    try {
      await _apiClient.putRequest('/ParticipantesSala/$salaId/aceptar/$usuarioId', {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Participante aceptado exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadRoomDetails();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al aceptar la solicitud.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rechazarSolicitud(String usuarioId) async {
    final String? salaId = _room?['id']?.toString();
    if (salaId == null) return;

    bool confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Rechazar solicitud?'),
        content: const Text('Este usuario será eliminado de la lista de pendientes.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Rechazar', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    ) ?? false;

    if (!confirmar) return;

    try {
      await _apiClient.deleteRequest('/ParticipantesSala/$salaId/rechazar/$usuarioId');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud rechazada.'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadRoomDetails();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al rechazar la solicitud.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // NUEVO: Método para EXPULSAR a un participante ya activo
  Future<void> _expulsarParticipante(String usuarioId, String nombreParticipante) async {
    final String? salaId = _room?['id']?.toString();
    if (salaId == null) return;

    bool confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Expulsar Participante?'),
        content: Text('¿Estás seguro de que deseas sacar a $nombreParticipante de la sala? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Expulsar', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    ) ?? false;

    if (!confirmar) return;

    try {
      // Reutilizamos el endpoint de "rechazar" porque a nivel de BD hace lo mismo (eliminar el registro)
      await _apiClient.deleteRequest('/ParticipantesSala/$salaId/rechazar/$usuarioId');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$nombreParticipante ha sido eliminado de la sala.'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadRoomDetails();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al expulsar al participante.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // NUEVO: Cuadro Modal para asignar turnos (Tómbola y Manual)
  void _mostrarModalAsignarTurnos(List<dynamic> participantesActivos) {
    // 1. Hacemos una copia local para jugar con el orden sin dañar los datos reales aún
    List<dynamic> listaTemporal = List.from(participantesActivos);
    // Ordenamos por turno actual para que la lista inicial tenga sentido
    listaTemporal.sort((a, b) => (a['numeroTurno'] ?? 0).compareTo(b['numeroTurno'] ?? 0));

    bool isGuardandoTurnos = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que el cuadro ocupe más altura
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        // 2. StatefulBuilder nos permite hacer setState SOLO dentro de este cuadro
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(modalContext).size.height * 0.75, // Ocupa el 75% de la pantalla
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- ENCABEZADO ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Asignar Turnos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(modalContext),
                      )
                    ],
                  ),
                  const Divider(),

                  // --- BOTÓN DE TÓMBOLA ---
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[800],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      // Al presionar, mezclamos la lista temporal
                      setModalState(() {
                        listaTemporal.shuffle(); 
                      });
                    },
                    icon: const Icon(Icons.casino),
                    label: const Text('Girar Tómbola (Aleatorio)', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text('O mantén presionado un usuario para ordenar manualmente:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ),

                 // --- LISTA ARRASTRABLE ---
                  Expanded(
                    child: ReorderableListView.builder(
                      // 👇 1. Desactivamos el comportamiento web
                      buildDefaultDragHandles: false, 
                      itemCount: listaTemporal.length,
                      onReorder: (int oldIndex, int newIndex) {
                        setModalState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1; // Ajuste nativo de Flutter al arrastrar hacia abajo
                          }
                          final item = listaTemporal.removeAt(oldIndex);
                          listaTemporal.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        final p = listaTemporal[index];
                        return Card(
                          key: ValueKey(p['usuarioId']), // OBLIGATORIO para ReorderableListView
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green[100],
                              child: Text(
                                '${index + 1}°', 
                                style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold)
                              ),
                            ),
                            title: Text(p['nombre'] ?? 'Usuario', style: const TextStyle(fontWeight: FontWeight.bold)),
                            
                            // 👇 2. Convertimos el ícono en la zona táctil exclusiva
                            trailing: ReorderableDragStartListener(
                              index: index, 
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.drag_handle, color: Colors.grey, size: 28),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // --- BOTÓN APLICAR Y GUARDAR ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: isGuardandoTurnos ? null : () async {
                        setModalState(() => isGuardandoTurnos = true); // Enciende la ruedita

                        // Armamos la lista para enviar a la API
                        List<Map<String, dynamic>> payload = [];
                        for (int i = 0; i < listaTemporal.length; i++) {
                          payload.add({
                            'usuarioId': listaTemporal[i]['usuarioId'],
                            'numeroTurno': i + 1,
                          });
                        }

                        // 3. Enviamos los datos
                        final resultado = await _apiClient.asignarTurnos(widget.roomId, payload);

                        if (mounted) {
                          setModalState(() => isGuardandoTurnos = false);
                          Navigator.pop(modalContext); // Cierra el cuadro
                          
                          // Mostramos el mensaje
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(resultado['mensaje']),
                              backgroundColor: resultado['success'] ? Colors.green : Colors.red,
                            ),
                          );

                          // Si fue exitoso, recargamos la pantalla del fondo para ver los turnos nuevos
                          if (resultado['success']) {
                            _loadRoomDetails();
                          }
                        }
                      },
                      child: isGuardandoTurnos
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Aplicar y Guardar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  //Iniciar San
  // Función para detonar el inicio del San
  Future<void> _iniciarSan() async {
    // 1. Mostrar diálogo de confirmación
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('¿Iniciar el San?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            'Una vez iniciado, el sistema generará el calendario de pagos.\n\n'
            '⚠️ Ya no podrás agregar participantes, expulsarlos, ni modificar los turnos. '
            '¿Estás seguro de que deseas cerrar el grupo y comenzar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sí, Iniciar San', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    // Si el usuario cancela, no hacemos nada
    if (confirmar != true) return;

    // 2. Ejecutar la petición si confirmó
    try {
      // 👇 AQUÍ ESTÁ LA CORRECCIÓN: usamos _apiClient y widget.roomId
      final response = await _apiClient.postRequest('/api/Salas/${widget.roomId}/iniciar', {});
      

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['mensaje'] ?? 'San iniciado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        // Recargamos los detalles para que la interfaz cambie al modo "En Curso"
        _loadRoomDetails(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar el San: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

 //*********FIN FUNCIONES********

 @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, 
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(context, _seHicieronCambios);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context, _seHicieronCambios); 
            },
          ),
          title: const Text('Detalles del San', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green[700],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _room == null
            ? const Center(child: Text('Error al cargar la sala'))
            : _buildRoomContent(),
            bottomNavigationBar: (widget.esAdministrador && _room?['estado'] == 1)
            ? SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, -4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0, 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 28),
                    label: const Text(
                      'INICIAR SAN',
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _iniciarSan,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildRoomContent() {
    final int frecuenciaId = _room?['frecuencia'] ?? 0; 
    
    String frecuenciaTexto = 'Desconocida';
    switch (frecuenciaId) {
      case 1: frecuenciaTexto = 'Semanal'; break;
      case 2: frecuenciaTexto = 'Quincenal'; break;
      case 3: frecuenciaTexto = 'Mensual'; break;
    }

    final cuota = _room?['montoCuota']?.toString() ?? '0';
    final limiteParticipantes = _room?['cantidadParticipantes']?.toString() ?? '0';
    final permiteMultiplesTurnos = _room?['permitirMultiplesTurnos'] ?? false;
    final permiteDesembolsoAnticipado = _room?['permiteDesembolsoAnticipado'] ?? false;
    
    final String fechaInicioRaw = _room?['fechaInicio']?.toString() ?? '';
    final String fechaInicioTexto = fechaInicioRaw.length >= 10 
        ? fechaInicioRaw.substring(0, 10) 
        : 'Por definir';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TARJETA DE CONFIGURACIÓN DE LA SALA
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _editandoNombre
                            ? TextField(
                                controller: _nombreController,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                ),
                                autofocus: true, 
                                textCapitalization: TextCapitalization.sentences,
                              )
                            : Text(
                                _room?['nombreSala'] ?? 'Sin Nombre',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                      ),
                      // 👇 OCULTO SI NO ES ADMIN
                      if (widget.esAdministrador)
                        IconButton(
                          icon: Icon(
                            _editandoNombre ? Icons.check_circle : Icons.edit,
                            color: _editandoNombre ? Colors.green : Colors.blue,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_editandoNombre) {
                                _room!['nombreSala'] = _nombreController.text.trim();
                              }
                              _editandoNombre = !_editandoNombre;
                            });
                          },
                        ),
                    ],
                  ),
                ),
                const Divider(),

                ListTile(
                  leading: const Icon(Icons.attach_money, color: Colors.green),
                  title: const Text('Cuota'),
                  subtitle: _editandoCuota
                      ? TextField(
                          controller: _cuotaController,
                          keyboardType: TextInputType.number, 
                          decoration: const InputDecoration(
                            isDense: true,
                            prefixText: 'RD\$ ', 
                          ),
                          autofocus: true,
                        )
                      : Text('RD\$ ${_room?['montoCuota'] ?? '0'}'),
                  // 👇 OCULTO SI NO ES ADMIN
                  trailing: widget.esAdministrador ? IconButton(
                    icon: Icon(
                      _editandoCuota ? Icons.check_circle : Icons.edit,
                      color: _editandoCuota ? Colors.green : Colors.grey[700],
                    ),
                    onPressed: () async {
                      if (!_editandoCuota) {
                        bool confirmado = await _confirmarEdicionCritica('la Cuota');
                        if (!confirmado) return; 
                        setState(() { _editandoCuota = true; });
                      } else {
                        double? nuevaCuota = double.tryParse(_cuotaController.text);
                        if (nuevaCuota == null || nuevaCuota <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Por favor, ingresa un monto válido mayor a 0.'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return; 
                        }
                        setState(() {
                          _room!['montoCuota'] = nuevaCuota;
                          _editandoCuota = false;
                        });
                      }
                    },
                  ) : null,
                ),

                ListTile(
                  leading: const Icon(Icons.calendar_month, color: Colors.orange),
                  title: const Text('Frecuencia'),
                  subtitle: _editandoFrecuencia
                      ? DropdownButton<int>(
                          value: _frecuenciaSeleccionada,
                          isDense: true,
                          isExpanded: true, 
                          underline: Container(height: 1, color: Colors.green), 
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('Semanal')),
                            DropdownMenuItem(value: 2, child: Text('Quincenal')),
                            DropdownMenuItem(value: 3, child: Text('Mensual')),
                          ],
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              setState(() { _frecuenciaSeleccionada = newValue; });
                            }
                          },
                        )
                      : Text(frecuenciaTexto), 
                  // 👇 OCULTO SI NO ES ADMIN
                  trailing: widget.esAdministrador ? IconButton(
                    icon: Icon(
                      _editandoFrecuencia ? Icons.check_circle : Icons.edit,
                      color: _editandoFrecuencia ? Colors.green : Colors.grey[700],
                    ),
                    onPressed: () async {
                      if (!_editandoFrecuencia) {
                        bool confirmado = await _confirmarEdicionCritica('la Frecuencia');
                        if (!confirmado) return;
                        
                        setState(() {
                          int valorActual = _room?['frecuencia'] ?? 3;
                          if (valorActual >= 1 && valorActual <= 3) {
                            _frecuenciaSeleccionada = valorActual;
                          } else {
                            _frecuenciaSeleccionada = 3; 
                          }
                          _editandoFrecuencia = true;
                        });
                      } else {
                        setState(() {
                          _room!['frecuencia'] = _frecuenciaSeleccionada;
                          _editandoFrecuencia = false; 
                        });
                      }
                    },
                  ) : null,
                ),

               ListTile(
                  leading: const Icon(Icons.people, color: Colors.blueGrey),
                  title: const Text('Límite de Participantes'),
                  subtitle: _editandoLimite
                      ? TextField(
                          controller: _limiteController,
                          keyboardType: TextInputType.number, 
                          decoration: const InputDecoration(
                            isDense: true,
                            suffixText: ' personas', 
                          ),
                          autofocus: true,
                        )
                      : Text('${_room?['cantidadParticipantes'] ?? '0'} personas'),
                  // 👇 OCULTO SI NO ES ADMIN
                  trailing: widget.esAdministrador ? IconButton(
                    icon: Icon(
                      _editandoLimite ? Icons.check_circle : Icons.edit,
                      color: _editandoLimite ? Colors.green : Colors.grey[700],
                    ),
                    onPressed: () async {
                      if (!_editandoLimite) {
                        bool confirmado = await _confirmarEdicionCritica('el Límite de Participantes');
                        if (!confirmado) return;
                        
                        setState(() { _editandoLimite = true; });
                      } else {
                        int? nuevoLimite = int.tryParse(_limiteController.text);
                        if (nuevoLimite == null || nuevoLimite < 2) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Por favor, ingresa un mínimo de 2 personas.'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return; 
                        }
                        setState(() {
                          _room!['limiteParticipantes'] = nuevoLimite;
                          _editandoLimite = false; 
                        });
                      }
                    },
                  ) : null,
                ),

                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.purple),
                  title: const Text('Fecha estimada de Inicio'),
                  subtitle: Builder(
                    builder: (context) {
                      String textoFecha = _room?['fechaInicio']?.toString() ?? 'Sin fecha asignada';
                      if (textoFecha.contains('T')) {
                        textoFecha = textoFecha.split('T')[0];
                      }
                      return Text(textoFecha);
                    }
                  ),
                  // 👇 OCULTO SI NO ES ADMIN
                  trailing: widget.esAdministrador ? IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey),
                    onPressed: _editarFechaInicio,
                  ) : null,
                ),
                const SizedBox(height: 8),
                const Divider(),

                // 2. REGLAS DE LA SALA (Switches)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Reglas del San',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Múltiples turnos por persona'),
                  activeColor: Colors.green,
                  value: _room?['permitirMultiplesTurnos'] ?? false, 
                  // 👇 DESHABILITADO SI NO ES ADMIN
                  onChanged: widget.esAdministrador ? (bool newValue) async {
                    bool confirmado = await _confirmarEdicionCritica('permitir Múltiples Turnos');
                    if (!confirmado) return; 
                    setState(() { _room!['permitirMultiplesTurnos'] = newValue; });
                  } : null, 
                ),
                SwitchListTile(
                  title: const Text('Desembolso dinámico'),
                  activeColor: Colors.green,
                  value: _room?['permiteDesembolsoAnticipado'] ?? false,
                  // 👇 DESHABILITADO SI NO ES ADMIN
                  onChanged: widget.esAdministrador ? (bool newValue) async {
                    bool confirmado = await _confirmarEdicionCritica('el Desembolso Dinámico');
                    if (!confirmado) return; 
                    setState(() { _room!['permiteDesembolsoAnticipado'] = newValue; });
                  } : null,
                ),
                const Divider(),

                // 👇 BOTÓN DE GUARDAR SOLO PARA EL ADMIN
                if (widget.esAdministrador)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: SizedBox(
                      width: double.infinity, 
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white, 
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: _isGuardando 
                            ? const SizedBox(
                                width: 20, height: 20, 
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          _isGuardando ? 'Guardando...' : 'Guardar Cambios',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _isGuardando ? null : _guardarCambios,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 15),

        // 3. SECCIÓN DE PARTICIPANTES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Participantes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // 👇 FILTRAMOS LOS ACTIVOS DIRECTAMENTE AQUÍ PARA EVITAR EL ERROR
              Builder(
                builder: (context) {
                  final List<dynamic> todos = _room?['participantes'] ?? [];
                  final List<dynamic> listaActivos = todos.where((p) => p['estadoParticipacion'] == 1).toList();

                  return Row(
                    children: [
                      // Botón de Tómbola / Turnos (Solo Admin, en reclutamiento y si hay gente)
                      if (widget.esAdministrador && _room?['estado'] == 1 && listaActivos.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.shuffle, color: Colors.orange[800]),
                          tooltip: 'Asignar Turnos',
                          onPressed: () => _mostrarModalAsignarTurnos(listaActivos),
                        ),
                      // Botón de Agregar
                      if (widget.esAdministrador)
                        TextButton.icon(
                          onPressed: _mostrarDialogoInvitacion, 
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar'),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 5),

          Builder(
            builder: (context) {
              final List<dynamic> todosLosParticipantes = _room!['participantes'] ?? [];
              
              final List<dynamic> pendientes = todosLosParticipantes
                  .where((p) => p['estadoParticipacion'] == 0).toList();
              
              final List<dynamic> activos = todosLosParticipantes
                  .where((p) => p['estadoParticipacion'] == 1).toList();

              activos.sort((a, b) => (a['numeroTurno'] ?? 0).compareTo(b['numeroTurno'] ?? 0));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 👇 B. LA SALA DE ESPERA (Solo si es admin y hay pendientes)
                  if (widget.esAdministrador && pendientes.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.orange[50], 
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(Icons.notifications_active, color: Colors.orange[800], size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Solicitudes Pendientes (${pendientes.length})', 
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[800])
                                ),
                              ],
                            ),
                          ),
                      // Dibujamos cada solicitud
                          ...pendientes.map((p) {
                            // 👇 MAGIA: Detectamos si la solicitud es del propio administrador
                            bool esElCreador = p['usuarioId'].toString() == _room!['creadorId'].toString();

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: esElCreador ? Colors.green[200] : Colors.orange[200], 
                                child: Icon(
                                  esElCreador ? Icons.admin_panel_settings : Icons.person, 
                                  color: esElCreador ? Colors.green[800] : Colors.orange[800]
                                )
                              ),
                              title: Text(
                                esElCreador ? 'Tú (Organizador)' : (p['nombre'] ?? 'Usuario Desconocido'), 
                                style: const TextStyle(fontWeight: FontWeight.bold)
                              ),
                              subtitle: Text(
                                esElCreador 
                                  ? '¿Seguro que deseas ocupar un turno en tu sala?' 
                                  : 'Quiere unirse al San', 
                                style: TextStyle(fontSize: 12, color: esElCreador ? Colors.green[800] : Colors.grey[700])
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Botón de Aceptar
                                  IconButton(
                                    icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                                    onPressed: () async {
                                      // Si es el creador, le lanzamos un aviso extra de confirmación
                                      if (esElCreador) {
                                        bool confirmar = await showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Unirte a tu sala'),
                                            content: const Text('Al unirte, ocuparás un cupo oficial como participante que debe aportar y recibir el pozo. ¿Deseas continuar?'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí, unirme')),
                                            ],
                                          ),
                                        ) ?? false;
                                        if (!confirmar) return; // Si cancela, nos detenemos
                                      }
                                      _aceptarSolicitud(p['usuarioId'].toString());
                                    },
                                  ),
                                  // Botón de Rechazar
                                  IconButton(
                                    icon: const Icon(Icons.cancel, color: Colors.red, size: 28),
                                    onPressed: () => _rechazarSolicitud(p['usuarioId'].toString()),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                  // 👇 C. LA LISTA OFICIAL (Los activos)
                  if (activos.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Center(
                        child: Text(
                          'Aún no hay participantes en este San.\n¡Empieza a agregar a tu grupo!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true, 
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activos.length,
                      itemBuilder: (context, index) {
                        final participante = activos[index];
                        
                        // Validamos si la sala sigue en estado 1 (Reclutamiento)
                        final bool enReclutamiento = _room?['estado'] == 1;

                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green[100],
                              child: Text(
                                participante['numeroTurno'] != 0 
                                  ? participante['numeroTurno'].toString() 
                                  : '✓',
                                style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(participante['nombre'] ?? 'Usuario'),
                            subtitle: const Text('Participante Activo'),
                            // 👇 NUEVO: Botón de expulsar (Solo para Admin + Fase de Reclutamiento)
                            trailing: (widget.esAdministrador && enReclutamiento)
                                ? IconButton(
                                    icon: const Icon(Icons.person_remove, color: Colors.redAccent),
                                    tooltip: 'Expulsar participante',
                                    onPressed: () => _expulsarParticipante(
                                      participante['usuarioId'].toString(),
                                      participante['nombre'] ?? 'Usuario'
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                ],
              );
            }
          ),
        ],
      ),

      
    );
  }
}