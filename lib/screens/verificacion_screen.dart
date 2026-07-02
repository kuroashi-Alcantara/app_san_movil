import 'package:flutter/material.dart';
import '../models/verificar_correo_model.dart';
import '../services/api_client.dart';
import 'login_screen.dart'; // Importa tu pantalla de Login para redirigir al usuario al terminar
// Importa tu pantalla de Login para redirigir al usuario al terminar
// import 'login_screen.dart';

class VerificacionScreen extends StatefulWidget {
  final String correo;

  const VerificacionScreen({super.key, required this.correo});

  @override
  State<VerificacionScreen> createState() => _VerificacionScreenState();
}

class _VerificacionScreenState extends State<VerificacionScreen> {
  final _codigoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _estaCargando = false;

  Future<void> _ejecutarVerificacion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _estaCargando = true);

    try {
      final api = ApiClient();
      final modelo = VerificarCorreoModel(
        correo: widget
            .correo, // Usamos el correo que recibimos de la pantalla anterior
        codigo: _codigoController.text.trim(),
      );

      await api.verificarCorreo(modelo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '¡Cuenta verificada con éxito! Ya puedes iniciar sesión.',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // SALTO AL LOGIN Y LIMPIEZA DE PANTALLAS
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) =>
              false, // Esto es lo que destruye el historial
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Código incorrecto o cuenta ya verificada.'),
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
        title: const Text('Verificar Cuenta'),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.mark_email_read,
                  size: 80,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Ingresa el código de 6 dígitos',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Se lo hemos enviado a:\n${widget.correo}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Campo para el código
                TextFormField(
                  controller: _codigoController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 8.0,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '000000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Ingresa el código';
                    if (value.length < 6)
                      return 'El código debe tener 6 dígitos';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Botón de Verificar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _estaCargando ? null : _ejecutarVerificacion,
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
                            'Verificar Correo',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ), // Espacio para separar del botón principal
                // Fila del botón de rescate
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿Te equivocaste de correo?',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        // El comando pop destruye la pantalla actual (Verificación)
                        // y devuelve al usuario a la pantalla de Registro.
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cambiar correo',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
    _codigoController.dispose();
    super.dispose();
  }
}
