import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'registro_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'verificacion_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.monetization_on,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Gestor de San',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Inicia sesión para continuar',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      // 1. Capturamos lo que el usuario escribió
                      String email = _emailController.text.trim();
                      String password = _passwordController.text.trim();

                      print("Botón presionado. Enviando datos...");

                      try {
                        // 2. Intentamos hacer el login
                        var respuesta = await _authService.loginUser(
                          email,
                          password,
                        );

                        // 3. Verificamos si el backend nos devolvió un token
                        if (respuesta != null &&
                            respuesta.containsKey('token')) {
                          final storage = const FlutterSecureStorage();

                          // Guardamos el token por seguridad
                          await storage.write(
                            key: 'token',
                            value: respuesta['token'].toString(),
                          );

                          // --- 🛠️ CORRECCIÓN DE LA LLAVE ---
                          // Buscamos 'nombre' (minúscula) o 'Nombre' (mayúscula) que es como lo envía C#
                          String nombreReal =
                              respuesta['nombre'] ??
                              respuesta['Nombre'] ??
                              'Usuario';

                          await storage.write(
                            key: 'nombre_usuario',
                            value: nombreReal,
                          );

                          await storage.write(
                            key: 'correo_usuario',
                            value: respuesta['correo'] ?? email,
                          );

                          // ¡Éxito! Hacemos el salto visual
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        // ELIMINAMOS la línea de _estaCargando que causaba el error

                        String mensajeError =
                            "Error de conexión o credenciales incorrectas.";
                        bool requiereVerificacion = false;

                        try {
                          dynamic error = e;
                          if (error.response != null &&
                              error.response.data != null) {
                            mensajeError =
                                error.response.data['mensaje'] ?? mensajeError;
                            requiereVerificacion =
                                error.response.data['requiereVerificacion'] ??
                                false;
                          }
                        } catch (_) {}

                        if (context.mounted) {
                          // Si el backend dice que requiere verificación
                          if (requiereVerificacion) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(mensajeError),
                                backgroundColor: Colors.orange,
                              ),
                            );

                            // Saltamos a la pantalla pasándole el correo
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VerificacionScreen(correo: email),
                              ),
                            );
                          } else {
                            // Si fue un error normal (contraseña mala, etc.)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(mensajeError),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: const Text(
                      'Ingresar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Un pequeño espacio de separación
                // Fila con el texto y el botón de registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes cuenta?',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        // Esta es la ruta que lleva al usuario a tu nueva pantalla
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegistroScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Regístrate aquí',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 16,
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
}
