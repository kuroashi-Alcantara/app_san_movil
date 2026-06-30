import 'package:flutter/material.dart';
import '../models/usuario_registro_model.dart';
import '../services/api_client.dart';
import 'verificacion_screen.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  // Llave para validar el formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();

  bool _estaCargando = false;

  // Función que se ejecuta al presionar "Registrarse"
  Future<void> _ejecutarRegistro() async {
    // Si el formulario no es válido (ej. campos vacíos), detenemos la función
    if (!_formKey.currentState!.validate()) return;

    setState(() => _estaCargando = true);

    try {
      final api = ApiClient();
      final nuevoUsuario = UsuarioRegistroModel(
        nombreCompleto: _nombreController.text.trim(),
        correo: _correoController.text.trim(),
        telefono: _telefonoController.text.trim(),
        contrasena: _contrasenaController.text.trim(),
      );

      // Enviamos los datos al backend
      final codigoSecreto = await api.registrarUsuario(nuevoUsuario);

      // Si fue exitoso, mostramos un mensaje y pasamos a la siguiente pantalla
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Registro exitoso! Código de prueba: $codigoSecreto',
            ),
          ),
        );

       // NAVEGACIÓN HACIA LA PANTALLA DE VERIFICACIÓN
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificacionScreen(
              correo: _correoController.text.trim(), // Pasamos el correo ingresado
            ),
          ),
        );
        print("Mandar a verificar el correo con el código: $codigoSecreto");
      }
    } catch (e) {
      // Si el correo ya existe o falla la red
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar: Intenta con otro correo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _estaCargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.person_add_alt_1,
                  size: 80,
                  color: Colors.blueGrey,
                ),
                const SizedBox(height: 20),

                // --- CAMPO NOMBRE ---
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre Completo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Ingresa tu nombre' : null,
                ),
                const SizedBox(height: 16),

                // --- CAMPO CORREO ---
                TextFormField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) => value!.isEmpty || !value.contains('@')
                      ? 'Ingresa un correo válido'
                      : null,
                ),
                const SizedBox(height: 16),

                // --- CAMPO TELÉFONO ---
                TextFormField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Ingresa tu teléfono' : null,
                ),
                const SizedBox(height: 16),

                // --- CAMPO CONTRASEÑA ---
                TextFormField(
                  controller: _contrasenaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) =>
                      value!.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 30),
                // --- NUEVO: CAMPO CONFIRMAR CONTRASEÑA ---
                TextFormField(
                  controller: _confirmarContrasenaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Repetir Contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_clock),
                  ),
                  // Aquí comparamos directamente con lo que tiene el primer controlador
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, confirma tu contraseña';
                    }
                    if (value != _contrasenaController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // --- BOTÓN DE REGISTRO ---
                ElevatedButton(
                  onPressed: _estaCargando ? null : _ejecutarRegistro,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _estaCargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Registrarse',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }
}
