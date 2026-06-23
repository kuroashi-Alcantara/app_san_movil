import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart'; // Esto nos permite usar kIsWeb

class AuthService {
  late String baseUrl;

  final _storage = const FlutterSecureStorage();

 AuthService() {
    if (kIsWeb) {
      // Apuntamos al puerto HTTP real que nos da tu backend
      baseUrl = "http://localhost:5296/api"; 
    } else if (Platform.isAndroid) {
      // El emulador usa la IP puente pero al mismo puerto HTTP seguro para Android
      baseUrl = "http://10.0.2.2:5296/api"; 
    }
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final String url = "$baseUrl/Usuario/login";
    print("Intentando conectar a: $url");

    try {
      // Usamos los nombres EXACTOS de tu UsuarioLoginDto en C#
      final Map<String, dynamic> bodyData = {
        "Correo": email,      
        "Contrasena": password 
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(bodyData),
      );

      print("Código de estado HTTP: ${response.statusCode}");
      print("Respuesta del servidor: ${response.body}");

      if (response.statusCode == 200) {
        print("¡Login exitoso! El backend nos aceptó.");
        
        // 1. Decodificamos el JSON
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // 2. Extraemos el token específico
        String token = responseData['token'];
        
        // 3. ¡Lo guardamos en la bóveda del celular!
        await _storage.write(key: 'auth_token', value: token);
        
        print("Token guardado de forma segura en el dispositivo.");

        // 4. Retornamos toda la data para que la pantalla pueda hacer el salto
        return responseData; 
      } else {
        print("Error en el login");
        return null; 
      }

    } catch (e) {
      print("Excepción capturada (Error crítico): $e");
    }
  }
}