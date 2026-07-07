import 'package:flutter/material.dart';
import '../services/api_client.dart'; 

class EditarPerfilScreen extends StatefulWidget {
  final String nombreInicial;
  final String telefonoInicial;

  const EditarPerfilScreen({
    required this.nombreInicial,
    required this.telefonoInicial,
    super.key,
  });

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;
  bool _cargando = false;
  
  final ApiClient _api = ApiClient(); 

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.nombreInicial);
    _telefonoController = TextEditingController(text: widget.telefonoInicial);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  // --- 1. GUARDAR DATOS BÁSICOS ---
  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    
    final res = await _api.actualizarPerfil(_nombreController.text, _telefonoController.text);
    setState(() => _cargando = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['mensaje'].toString()),
        backgroundColor: res['success'] == true ? Colors.green : Colors.red,
      ));
      if (res['success'] == true) Navigator.pop(context, true); 
    }
  }

  // --- 2. VENTANA EMERGENTE PARA CAMBIAR CONTRASEÑA ---
  void _mostrarDialogoContrasena() {
    final passFormKey = GlobalKey<FormState>();
    final actualController = TextEditingController();
    final nuevaController = TextEditingController();
    bool cargandoPass = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Evita que se cierre tocando afuera si está cargando
      builder: (context) {
        // StatefulBuilder nos permite actualizar la pantalla SOLO dentro de la ventana emergente
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Text('Cambiar Contraseña', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Form(
                key: passFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: actualController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Contraseña Actual', prefixIcon: Icon(Icons.lock_outline)),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: nuevaController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Nueva Contraseña', prefixIcon: Icon(Icons.lock)),
                      validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                    ),
                  ],
                ),
              ),
              actions: [
                if (!cargandoPass) // Si está cargando, escondemos el botón de cancelar
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                  ),
                cargandoPass
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: CircularProgressIndicator(),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                        onPressed: () async {
                          if (passFormKey.currentState!.validate()) {
                            setStateDialog(() => cargandoPass = true); // Mostramos el circulito de carga
                            
                            final res = await _api.cambiarContrasena(
                              actualController.text, 
                              nuevaController.text
                            );
                            
                            setStateDialog(() => cargandoPass = false);

                            if (mounted) {
                              Navigator.pop(context); // Cerramos la ventana emergente
                              ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
                                content: Text(res['mensaje'].toString()),
                                backgroundColor: res['success'] == true ? Colors.green : Colors.red,
                              ));
                            }
                          }
                        },
                        child: const Text('Actualizar', style: TextStyle(color: Colors.white)),
                      ),
              ],
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
        title: const Text('Editar Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: _cargando 
        ? const Center(child: CircularProgressIndicator(color: Colors.green))
        : Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre Completo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) => v!.isEmpty ? 'El nombre no puede estar vacío' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _telefonoController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (v) => v!.isEmpty ? 'El teléfono no puede estar vacío' : null,
                  ),
                  const SizedBox(height: 30),
                  
                  // Botón 1: Guardar Cambios (Nombre y Teléfono)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _guardarCambios,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text('Guardar Cambios', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  const SizedBox(height: 15),

                  // Botón 2: Cambiar Contraseña (Abre la ventana emergente)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(color: Colors.green[700]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _mostrarDialogoContrasena, // Llama a la función de arriba
                    icon: Icon(Icons.key, color: Colors.green[700]),
                    label: Text('Cambiar Contraseña', style: TextStyle(fontSize: 16, color: Colors.green[700])),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}