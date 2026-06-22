import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  late String baseUrl;

  AuthService() {
    if (kIsWeb) {
      baseUrl = "https://localhost:7224/api";
    } else if (Platform.isAndroid) {
      baseUrl = "https://10.0.2.2:7224/api";
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
        print("Respuesta del servidor: ${response.body}");
        print("¡Login exitoso! El backend nos aceptó.");
        
        return jsonDecode(response.body);
      } else {
        print("El backend rechazó la petición. Revisa las credenciales.");
      }

    } catch (e) {
      print("Excepción capturada (Error crítico): $e");
    }
  }
}