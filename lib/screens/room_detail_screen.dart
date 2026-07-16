import 'package:flutter/material.dart';
import '/services/api_client.dart';
import 'package:flutter/services.dart';

class RoomDetailScreen extends StatefulWidget {
  final String roomId;

  const RoomDetailScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  final ApiClient _apiClient = ApiClient();
  Map<String, dynamic>? _room;
  bool _isLoading = true;

  // NUEVO: Variables para la edición en línea del nombre
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
    _nombreController.dispose(); // liberar la memoria
    _cuotaController.dispose(); // liberar la memoria   
    _limiteController.dispose(); // liberar la memoria
    super.dispose();
  }

  //*******FUNCIONES*******

  Future<void> _loadRoomDetails() async {
    setState(() => _isLoading = true);

    // AQUÍ HACEMOS LA LLAMADA REAL AL BACKEND
    final data = await _apiClient.obtenerDetalleSala(widget.roomId);

    setState(() {
      _room = data;
      _nombreController.text = _room?['nombreSala'] ?? '';
      _cuotaController.text = _room?['montoCuota']?.toString() ?? '0';
      _limiteController.text = _room?['cantidadParticipantes']?.toString() ?? '0';
      _isLoading = false;
    });
  }

  //metodo para validacion de edicion de campos criticos
  Future<bool> _confirmarEdicionCritica(String campo) async {
    // Si la sala ya empezó o quieres poner reglas más estrictas, las evaluarías aquí.
    
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
            onPressed: () => Navigator.pop(context, false), // Retorna false
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(context, true), // Retorna true
            child: const Text('Sí, editar'),
          ),
        ],
      ),
    );

    // Si el usuario toca fuera del cuadro, retorna null, lo tomamos como false
    return resultado ?? false; 
  }

 Future<void> _editarFechaInicio() async {
    // Recuerda usar la llave correcta (ej. 'fechaInicio' o 'fechaEstimadaInicio')
    String fechaActualStr = _room?['fechaInicio']?.toString() ?? '';
    
    DateTime ahora = DateTime.now();
    DateTime fechaInicial = ahora;
    
    if (fechaActualStr.isNotEmpty) {
      DateTime? fechaParseada = DateTime.tryParse(fechaActualStr);
      if (fechaParseada != null) {
        fechaInicial = fechaParseada;
      }
    }

    // LA MAGIA ESTÁ AQUÍ: Ajustamos el límite inferior para evitar el crasheo
    DateTime primeraFechaPermitida = ahora;
    if (fechaInicial.isBefore(ahora)) {
      primeraFechaPermitida = fechaInicial; // Si es vieja, el calendario iniciará desde ese día
    }

    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: primeraFechaPermitida, // Usamos nuestra variable ajustada
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

    // 1. Encendemos la animación de carga
    setState(() {
      _isGuardando = true;
    });

    try {
      // Asumimos que tienes una instancia de tu ApiClient o la llamas directamente
      final apiClient = ApiClient(); 
      
      // Obtenemos el ID de la sala. Asegúrate de usar la llave correcta (ej. 'id' o 'salaId')
      String salaId = _room!['id'].toString(); 

      // 2. Enviamos el mapa modificado completo al backend
      final resultado = await apiClient.actualizarSala(salaId, _room!);

      // 3. Verificamos que la pantalla siga visible antes de mostrar el mensaje
      if (!mounted) return;

      // Si fue exitoso, encendemos la bandera
      if (resultado['success'] == true) {
        _seHicieronCambios = true;
      }

      // 4. Mostramos el resultado
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
      // 5. Apagamos la animación de carga pase lo que pase
      if (mounted) {
        setState(() {
          _isGuardando = false;
        });
      }
    }
  }

  // Función para mostrar el diálogo de invitación
  void _mostrarDialogoInvitacion() {
    // Tomamos el ID de la sala que ya tenemos en memoria
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
              // Caja con el código resaltado
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
                // 👇 MAGIA NATIVA: Copia el texto al portapapeles del celular
                Clipboard.setData(ClipboardData(text: codigoSala));
                Navigator.pop(context); // Cierra el modal
                
                // Avisamos al usuario que se copió
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

  
 //*********FIN FUNCIONES********

 @override
  Widget build(BuildContext context) {
    // 👇 PopScope atrapa el gesto de retroceso físico del celular (Android)
    return PopScope(
      canPop: false, // Bloqueamos el retroceso automático
      onPopInvoked: (didPop) {
        if (didPop) return;
        // Ejecutamos nuestro retroceso manual con la bandera
        Navigator.pop(context, _seHicieronCambios);
      },
      child: Scaffold(
        appBar: AppBar(
          // 👇 leading atrapa el toque en la flecha de la pantalla
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
      ),
    );
  }

  Widget _buildRoomContent() {

  // 1. Extraemos el número crudo que envía tu API
    final int frecuenciaId = _room?['frecuencia'] ?? 0; 
    
    // 2. Lo traducimos basándonos en tu Enum de C#
    String frecuenciaTexto = 'Desconocida';
    switch (frecuenciaId) {
      case 1: 
        frecuenciaTexto = 'Semanal'; 
        break;
      case 2: 
        frecuenciaTexto = 'Quincenal'; 
        break;
      case 3: 
        frecuenciaTexto = 'Mensual'; 
        break;
    }

    // Extraemos las variables del mapa para que el código sea más limpio.
    // Ajusta las llaves ('nombreSala', etc.) si tu API las manda en mayúscula inicial.
    //final nombre = _room?['nombreSala'] ?? 'Sin Nombre';
    final cuota = _room?['montoCuota']?.toString() ?? '0';

    //final frecuencia = _room?['frecuencia']?.toString() ?? 'Desconocida';
    final limiteParticipantes = _room?['cantidadParticipantes']?.toString() ?? '0';

    // Asumimos que tu backend devuelve los booleanos, si son null ponemos false por defecto
    final permiteMultiplesTurnos = _room?['permitirMultiplesTurnos'] ?? false;
    final permiteDesembolsoAnticipado =
        _room?['permiteDesembolsoAnticipado'] ?? false;
    
    
    final String fechaInicioRaw = _room?['fechaInicio']?.toString() ?? '';
    // Tomamos solo los primeros 10 caracteres (YYYY-MM-DD) si viene completa
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
                // Título y edición en línea
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
                                autofocus: true, // Abre el teclado automáticamente
                                textCapitalization: TextCapitalization.sentences,
                              )
                            : Text(
                                _room?['nombreSala'] ?? 'Sin Nombre',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                      ),
                      IconButton(
                        // Cambiamos el ícono y el color dependiendo del estado
                        icon: Icon(
                          _editandoNombre ? Icons.check_circle : Icons.edit,
                          color: _editandoNombre ? Colors.green : Colors.blue,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_editandoNombre) {
                              // Si estábamos editando, guardamos el nuevo valor en la memoria de la pantalla
                              _room!['nombreSala'] = _nombreController.text.trim();
                            }
                            // Alternamos el estado (si era true pasa a false, y viceversa)
                            _editandoNombre = !_editandoNombre;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // Campos críticos (Requieren validación)
                ListTile(
                  leading: const Icon(Icons.attach_money, color: Colors.green),
                  title: const Text('Cuota'),
                  
                  // 👇 1. EL SUBTÍTULO AHORA ESCUCHA A LA VARIABLE
                  subtitle: _editandoCuota
                      ? TextField(
                          controller: _cuotaController,
                          keyboardType: TextInputType.number, // Abre teclado numérico
                          decoration: const InputDecoration(
                            isDense: true,
                            prefixText: 'RD\$ ', // Deja el símbolo de moneda fijo
                          ),
                          autofocus: true,
                        )
                      : Text('RD\$ ${_room?['montoCuota'] ?? '0'}'),
                  
                  // 👇 2. EL ÍCONO TAMBIÉN ESCUCHA A LA VARIABLE
                  trailing: IconButton(
                    icon: Icon(
                      _editandoCuota ? Icons.check_circle : Icons.edit,
                      color: _editandoCuota ? Colors.green : Colors.grey[700],
                    ),
                    onPressed: () async {
                      if (!_editandoCuota) {
                        // --- CAMINO 1: VAMOS A ABRIR EL MODO EDICIÓN ---
                        // Pedimos permiso primero
                        bool confirmado = await _confirmarEdicionCritica('la Cuota');
                        if (!confirmado) return; // Si cancela, no hacemos nada
                        
                        // Si acepta, encendemos el modo edición
                        setState(() {
                          _editandoCuota = true;
                        });
                        
                      } else {
                        // --- CAMINO 2: VAMOS A GUARDAR (Click en el check verde) ---
                        // Intentamos convertir el texto
                        double? nuevaCuota = double.tryParse(_cuotaController.text);
                        
                        // Validamos si introdujo letras o cero
                        if (nuevaCuota == null || nuevaCuota <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Por favor, ingresa un monto válido mayor a 0.'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return; // Detenemos la ejecución aquí, NO cerramos el modo edición
                        }
                        
                        // Si el número es válido, guardamos en memoria y cerramos edición
                        setState(() {
                          _room!['montoCuota'] = nuevaCuota;
                          _editandoCuota = false;
                        });
                      }
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month, color: Colors.orange),
                  title: const Text('Frecuencia'),
                  
                  // 👇 1. EL SUBTÍTULO CAMBIA A UN MENÚ DESPLEGABLE EN MODO EDICIÓN
                  subtitle: _editandoFrecuencia
                      ? DropdownButton<int>(
                          value: _frecuenciaSeleccionada,
                          isDense: true,
                          isExpanded: true, // Para que ocupe el ancho disponible
                          underline: Container(height: 1, color: Colors.green), // Subrayado verde
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('Semanal')),
                            DropdownMenuItem(value: 2, child: Text('Quincenal')),
                            DropdownMenuItem(value: 3, child: Text('Mensual')),
                          ],
                          onChanged: (int? newValue) {
                            // Cuando el usuario elige una opción en el menú, actualizamos el valor en pantalla
                            if (newValue != null) {
                              setState(() {
                                _frecuenciaSeleccionada = newValue;
                              });
                            }
                          },
                        )
                      : Text(frecuenciaTexto), // frecuenciaTexto es el switch que hicimos antes
                  
                  // 👇 2. EL BOTÓN CON LA LÓGICA DE DOS CAMINOS
                  trailing: IconButton(
                    icon: Icon(
                      _editandoFrecuencia ? Icons.check_circle : Icons.edit,
                      color: _editandoFrecuencia ? Colors.green : Colors.grey[700],
                    ),
                    onPressed: () async {
                      if (!_editandoFrecuencia) {
                        // --- CAMINO 1: ABRIR MODO EDICIÓN ---
                        bool confirmado = await _confirmarEdicionCritica('la Frecuencia');
                        if (!confirmado) return;
                        
                        setState(() {
                          // Tomamos el valor actual de la sala para que el menú inicie en esa opción
                          int valorActual = _room?['frecuencia'] ?? 3;
                          // Pequeña validación por si el backend mandó un número raro
                          if (valorActual >= 1 && valorActual <= 3) {
                            _frecuenciaSeleccionada = valorActual;
                          } else {
                            _frecuenciaSeleccionada = 3; 
                          }
                          _editandoFrecuencia = true;
                        });
                        
                      } else {
                        // --- CAMINO 2: GUARDAR ---
                        // No necesitamos validación de formato aquí porque el DropdownButton
                        // solo permite elegir 1, 2 o 3. Es imposible equivocarse.
                        setState(() {
                          // Guardamos el número (1, 2 o 3) en el mapa del backend
                          _room!['frecuencia'] = _frecuenciaSeleccionada;
                          _editandoFrecuencia = false; // Cerramos modo edición
                        });
                      }
                    },
                  ),
                ),
               ListTile(
                  leading: const Icon(Icons.people, color: Colors.blueGrey),
                  title: const Text('Límite de Participantes'),
                  
                  // 👇 1. MODO LECTURA VS MODO EDICIÓN
                  subtitle: _editandoLimite
                      ? TextField(
                          controller: _limiteController,
                          keyboardType: TextInputType.number, // Teclado numérico
                          decoration: const InputDecoration(
                            isDense: true,
                            suffixText: ' personas', // Texto al final
                          ),
                          autofocus: true,
                        )
                      : Text('${_room?['cantidadParticipantes'] ?? '0'} personas'),
                  
                  // 👇 2. LOS DOS CAMINOS: CONFIRMAR Y GUARDAR
                  trailing: IconButton(
                    icon: Icon(
                      _editandoLimite ? Icons.check_circle : Icons.edit,
                      color: _editandoLimite ? Colors.green : Colors.grey[700],
                    ),
                    onPressed: () async {
                      if (!_editandoLimite) {
                        // --- CAMINO 1: ABRIR MODO EDICIÓN ---
                        bool confirmado = await _confirmarEdicionCritica('el Límite de Participantes');
                        if (!confirmado) return;
                        
                        setState(() {
                          _editandoLimite = true;
                        });
                        
                      } else {
                        // --- CAMINO 2: GUARDAR Y VALIDAR ---
                        // Intentamos convertir a entero puro
                        int? nuevoLimite = int.tryParse(_limiteController.text);
                        
                        // Validamos que sean al menos 2 personas
                        if (nuevoLimite == null || nuevoLimite < 2) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Por favor, ingresa un mínimo de 2 personas.'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return; // No lo dejamos guardar
                        }
                        
                        // Si todo está bien, guardamos
                        setState(() {
                          _room!['limiteParticipantes'] = nuevoLimite;
                          _editandoLimite = false; // Cerramos modo edición
                        });
                      }
                    },
                  ),
                ),

                 //const Divider(),

                // NUEVO CAMPO: Fecha de Inicio
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.purple),
                  title: const Text('Fecha estimada de Inicio'),
                  subtitle: Builder(
                    builder: (context) {
                      // Obtenemos el texto de la base de datos
                      String textoFecha = _room?['fechaInicio']?.toString() ?? 'Sin fecha asignada';
                      // Si tiene la T de la base de datos, la cortamos para mostrar solo "YYYY-MM-DD"
                      if (textoFecha.contains('T')) {
                        textoFecha = textoFecha.split('T')[0];
                      }
                      return Text(textoFecha);
                    }
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey),
                    onPressed: _editarFechaInicio,
                  ),
                ),

                const SizedBox(height: 8),

                const Divider(),

                // 2. REGLAS DE LA SALA (Switches)
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
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
               // --- SWITCH 1: Múltiples turnos ---
                SwitchListTile(
                  title: const Text('Múltiples turnos por persona'),
                  activeColor: Colors.green,
                  // 👇 Leemos directamente de la memoria en tiempo real
                  value: _room?['permitirMultiplesTurnos'] ?? false, 
                  onChanged: (bool newValue) async {
                    // 1. Pedimos confirmación antes de cambiar
                    bool confirmado = await _confirmarEdicionCritica('permitir Múltiples Turnos');
                    if (!confirmado) return; // Si cancela, no hacemos nada

                    // 2. Si acepta, actualizamos la memoria y el switch cambia de color
                    setState(() {
                      _room!['permitirMultiplesTurnos'] = newValue;
                    });
                  },
                ),

                // --- SWITCH 2: Desembolso dinámico ---
                SwitchListTile(
                  title: const Text('Desembolso dinámico'),
                  activeColor: Colors.green,
                  // 👇 Leemos directamente de la memoria en tiempo real
                  value: _room?['permiteDesembolsoAnticipado'] ?? false,
                  onChanged: (bool newValue) async {
                    // 1. Pedimos confirmación antes de cambiar
                    bool confirmado = await _confirmarEdicionCritica('el Desembolso Dinámico');
                    if (!confirmado) return; // Si cancela, no hacemos nada

                    // 2. Si acepta, actualizamos la memoria y el switch cambia de color
                    setState(() {
                      _room!['permiteDesembolsoAnticipado'] = newValue;
                    });
                  },
                ),

                const Divider(),

                //const SizedBox(height: 8),

                // NUEVO BOTÓN: Guardar Cambios
              // NUEVO BOTÓN: Guardar Cambios (Conectado y Reactivo)
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
                      // 👇 Alterna entre el icono de disco y el círculo de carga
                      icon: _isGuardando 
                          ? const SizedBox(
                              width: 20, 
                              height: 20, 
                              child: CircularProgressIndicator(
                                strokeWidth: 2, 
                                color: Colors.white
                              )
                            )
                          : const Icon(Icons.save),
                      // 👇 Alterna el texto
                      label: Text(
                        _isGuardando ? 'Guardando...' : 'Guardar Cambios',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      // 👇 Deshabilita el botón (poniéndolo null) si ya está guardando
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
              TextButton.icon(
                // 👇 AQUÍ ES EL ÚNICO CAMBIO: Llamamos a la función
                onPressed: _mostrarDialogoInvitacion, 
                icon: const Icon(Icons.add),
                label: const Text('Agregar'),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // Tu diseño del contenedor vacío se queda intacto
          Container(
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
          ),
        ],
      ),
    );
  }
}
