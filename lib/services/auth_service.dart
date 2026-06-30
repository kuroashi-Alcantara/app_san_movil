import 'dart:io' show Platform;
import 'package:dio/dio.dart'; 
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  late String baseUrl;
  final _storage = const FlutterSecureStorage();
  final Dio _dio = Dio(); 

  AuthService() {
    if (kIsWeb) {
      baseUrl = "http://localhost:5296/api"; 
    } else if (Platform.isAndroid) {
      baseUrl = "http://10.0.2.2:5296/api"; 
    }
    _dio.options.baseUrl = baseUrl;
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final String endpoint = "/Usuario/login";
    print("Intentando conectar a: $baseUrl$endpoint");

    try {
      final response = await _dio.post(
        endpoint,
        data: {
          "Correo": email,      
          "Contrasena": password 
        },
      );

      print("Código de estado HTTP: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("¡Login exitoso! El backend nos aceptó.");
        
        final Map<String, dynamic> responseData = response.data;
        String token = responseData['token'];
        
        await _storage.write(key: 'auth_token', value: token);
        
        return responseData; 
      }
    } on DioException catch (e) {
      print("Error de conexión (DioException): ${e.response?.statusCode} - ${e.message}");
      
      // EL CAMBIO CLAVE: Relanzamos el error para que la pantalla de Login 
      // entre en su propio bloque catch(e) y lea los datos del error.
      rethrow; 
      
    } catch (e) {
      print("Excepción capturada (Error crítico): $e");
      
      // También relanzamos cualquier otro error inesperado
      rethrow; 
    }
    
    return null; 
  }
}