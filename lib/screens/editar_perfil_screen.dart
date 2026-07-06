import 'package:flutter/material.dart';
// Importa tu ApiService aquí (ej: import 'api_service.dart';)

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

  // Controladores para capturar lo que el usuario escribe
  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;

  bool _cargando = false;
  // Instancia ficticia de tu servicio, adáptala a tu código
  // final apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Precargamos los datos que vienen de la pantalla de perfil
    _nombreController = TextEditingController(text: widget.nombreInicial);
    _telefonoController = TextEditingController(text: widget.telefonoInicial);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  // --- LÓGICA PARA MANDAR LOS DATOS BÁSICOS A C# ---
  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    // Llamamos al método del Paso 1
    // final resultado = await apiService.actualizarPerfil(_nombreController.text, _telefonoController.text);
    final resultado = {
      'success': true,
      'mensaje': 'Simulación exitosa',
    }; // Temporal

    setState(() => _cargando = false);

    if (resultado['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Perfil actualizado correctamente!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(
        context,
        true,
      ); // Regresa a la pantalla anterior avisando que hubo cambios
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['mensaje']?.toString() ?? 'Error'),
          backgroundColor: Colors
              .green, // ¡Asegúrate de que esta llave esté al mismo nivel que 'content'!
        ),
      );
    }
  }

  // --- 🖼️ VENTANA EMERGENTE PARA CAMBIAR CONTRASENA ---
  void _mostrarDialogoContrasena() {
    final _passFormKey = GlobalKey<FormState>();
    final _actualController = TextEditingController();
    final _nuevaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Cambiar Contraseña',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: _passFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _actualController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña Actual',
                    icon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nuevaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nueva Contraseña',
                    icon: Icon(Icons.lock_open),
                  ),
                  validator: (v) =>
                      v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
              ),
              onPressed: () async {
                if (_passFormKey.currentState!.validate()) {
                  // Aquí llamarías a: await apiService.cambiarContrasena(_actualController.text, _nuevaController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contraseña modificada'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text(
                'Actualizar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
                      validator: (v) =>
                          v!.isEmpty ? 'El nombre no puede estar vacío' : null,
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
                      validator: (v) => v!.isEmpty
                          ? 'El teléfono no puede estar vacío'
                          : null,
                    ),
                    const SizedBox(height: 30),

                    // Botón Principal: Guardar Cambios
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _guardarCambios,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text(
                        'Guardar Cambios',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Botón Secundario: Abrir Ventana Emergente de Contraseña
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: BorderSide(color: Colors.green[700]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _mostrarDialogoContrasena,
                      icon: Icon(Icons.key, color: Colors.green[700]),
                      label: Text(
                        'Cambiar Contraseña',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
