import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener este paquete en pubspec.yaml para formatear la fecha

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiClient _api = ApiClient();

  // Controladores de texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _participantesController = TextEditingController();

  // Variables de estado para los selectores
  int _frecuenciaSeleccionada = 1; // 1 = Semanal por defecto
  DateTime _fechaInicio = DateTime.now().add(const Duration(days: 1)); // Mañana por defecto
  bool _multiplesTurnos = false;
  bool _desembolsoAnticipado = false;
  
  bool _cargando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _montoController.dispose();
    _participantesController.dispose();
    super.dispose();
  }

  // --- FUNCIÓN PARA EL CALENDARIO ---
  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? seleccion = await showDatePicker(
      context: context,
      initialDate: _fechaInicio,
      firstDate: DateTime.now(), // No se puede crear un San en el pasado
      lastDate: DateTime(DateTime.now().year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green[700]!, // Color del encabezado y selección
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (seleccion != null && seleccion != _fechaInicio) {
      setState(() {
        _fechaInicio = seleccion;
      });
    }
  }

  // --- LÓGICA PARA CREAR LA SALA ---
  Future<void> _crearSala() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    // Armamos el diccionario exacto que C# espera, ocultando "EsPublica"
    final nuevaSalaData = {
      'NombreSala': _nombreController.text.trim(),
      'MontoCuota': double.parse(_montoController.text.trim()),
      'Frecuencia': _frecuenciaSeleccionada,
      'CantidadParticipantes': int.parse(_participantesController.text.trim()),
      'EsPublica': false, // Siempre privada para la Versión 1.0
      'PermitirMultiplesTurnos': _multiplesTurnos,
      'DesembolsoAnticipado': _desembolsoAnticipado,
      'FechaInicio': _fechaInicio.toIso8601String(), // Formato estándar universal
    };

    final res = await _api.crearSala(nuevaSalaData);

    setState(() => _cargando = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['mensaje'].toString()),
        backgroundColor: res['success'] == true ? Colors.green : Colors.red,
      ));

      if (res['success'] == true) {
        // Regresamos a la pantalla anterior avisando que hubo éxito para que recargue la lista
        Navigator.pop(context, true); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Crear Nuevo San', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- SECCIÓN 1: DETALLES DEL SAN ---
                    _buildSeccionTitulo('Detalles Principales'),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nombreController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre del San',
                                prefixIcon: Icon(Icons.edit),
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _montoController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Monto de la Cuota (RD\$)',
                                prefixIcon: Icon(Icons.attach_money),
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) {
                                if (v!.isEmpty) return 'Requerido';
                                if (double.tryParse(v) == null) return 'Monto inválido';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- SECCIÓN 2: DINÁMICA ---
                    _buildSeccionTitulo('Dinámica del Juego'),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _participantesController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Cantidad de Participantes (Números)',
                                prefixIcon: Icon(Icons.groups),
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) {
                                if (v!.isEmpty) return 'Requerido';
                                if (int.tryParse(v) == null || int.parse(v) < 2) return 'Mínimo 2 participantes';
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            DropdownButtonFormField<int>(
                              value: _frecuenciaSeleccionada,
                              decoration: const InputDecoration(
                                labelText: 'Frecuencia de Pago',
                                prefixIcon: Icon(Icons.repeat),
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 1, child: Text('Semanal')),
                                DropdownMenuItem(value: 2, child: Text('Quincenal')),
                                DropdownMenuItem(value: 3, child: Text('Mensual')),
                              ],
                              onChanged: (int? newValue) {
                                setState(() {
                                  _frecuenciaSeleccionada = newValue!;
                                });
                              },
                            ),
                            const SizedBox(height: 15),
                            InkWell(
                              onTap: () => _seleccionarFecha(context),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Fecha Estimada de Inicio',
                                  prefixIcon: Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  DateFormat('dd / MM / yyyy').format(_fechaInicio),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                  // --- SECCIÓN 3: REGLAS ---
                    _buildSeccionTitulo('Reglas'),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          SwitchListTile(
                            activeColor: Colors.green[700],
                            title: const Text('Permitir Múltiples Turnos', style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text('Una misma persona puede tener más de un número.'),
                            value: _multiplesTurnos,
                            onChanged: (bool valor) {
                              setState(() {
                                _multiplesTurnos = valor;
                              });
                            },
                          ),
                          const Divider(height: 1), // Separador visual elegante
                          SwitchListTile(
                            activeColor: Colors.green[700],
                            title: const Text('Desembolso Dinámico', style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text('Permite flexibilidad de días para el pago y entrega.'),
                            value: _desembolsoAnticipado,
                            onChanged: (bool valor) {
                              setState(() {
                                _desembolsoAnticipado = valor;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- BOTÓN GUARDAR ---
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _crearSala,
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text('Crear San', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  // Pequeño widget reutilizable para los títulos de sección
  Widget _buildSeccionTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        titulo,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
      ),
    );
  }
}