import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/usuario_respuesta_model.dart';
import '../models/usuario_actualizar_model.dart';
import '../models/usuario_registro_model.dart';
import '../models/verificar_correo_model.dart';

class ApiClient {
  // Creamos la instancia principal de Dio
  final Dio _dio = Dio();

  // Usamos late porque le daremos valor en el constructor
  late String _baseUrl;

  // Apuntamos a la misma bóveda segura que usa tu AuthService
  final _storage = const FlutterSecureStorage();

  ApiClient() {
    // 1. Lógica dinámica de la URL (Igual que en AuthService)
    if (kIsWeb) {
      _baseUrl = "http://localhost:5296/api";
    } else if (Platform.isAndroid) {
      _baseUrl = "http://10.0.2.2:5296/api";
    } else {
      _baseUrl = "http://localhost:5296/api"; // Fallback de seguridad
    }

    // Configuración base
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // EL INTERCEPTOR: La magia de Dio
    _dio.interceptors.add(
      InterceptorsWrapper(
        // Antes de que la petición salga hacia C#...
        onRequest: (options, handler) async {
          // 2. Buscamos el token en nuestra bóveda usando la llave correcta
          final token = await _storage.read(key: 'auth_token');

          // 3. Si el token existe, se lo inyectamos a la cabecera
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // 4. Continuamos el viaje de la petición
          return handler.next(options);
        },

        // Si C# nos devuelve un error...
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            print('Error 401: Token expirado o no autorizado');
            // Aquí en el futuro enviaremos al usuario al LoginScreen
          }
          return handler.next(e);
        },
      ),
    );
  }

  // MÉTODO GET GENÉRICO
  Future<Response> getRequest(String endpoint) async {
    try {
      return await _dio.get(endpoint);
    } catch (e) {
      rethrow;
    }
  }

  // MÉTODO POST GENÉRICO (Para crear Salas, Movimientos, etc.)
  Future<Response> postRequest(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      return await _dio.post(endpoint, data: data);
    } catch (e) {
      rethrow;
    }
  }

  // MÉTODO PUT GENÉRICO
  Future<Response> putRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      return await _dio.put(endpoint, data: data);
    } catch (e) {
      rethrow;
    }
  }

  /// Registra un nuevo usuario y devuelve el código secreto (solo para desarrollo)
  Future<String> registrarUsuario(UsuarioRegistroModel modelo) async {
    try {
      final response = await postRequest('/usuario/registro', modelo.toJson());
      
      // Extraemos el código que C# nos mandó para poder probar la verificación
      return response.data['codigoSecretoParaPruebas'].toString();
    } catch (e) {
      print("Error en el registro: $e");
      rethrow;
    }
  }

  /// Envía el código para activar la cuenta del usuario
  Future<void> verificarCorreo(VerificarCorreoModel modelo) async {
    try {
      // Apuntamos al endpoint que creaste en C#
      await postRequest('/usuario/verificar-correo', modelo.toJson());
    } catch (e) {
      print("Error al verificar el correo: $e");
      rethrow;
    }
  }

  

  //Metodo mostrar perfil logueado
  Future<UsuarioRespuestaModel> obtenerPerfilUsuario() async {
    try {
      // Fíjate que aquí lo cambié a /usuario/perfil para que coincida 100% con tu C#
      final response = await getRequest('/usuario/perfil');

      return UsuarioRespuestaModel.fromJson(response.data);
    } catch (e) {
      print("Error al obtener el perfil: $e");
      rethrow;
    }
  }

  Future<void> actualizarPerfilUsuario(UsuarioActualizarModel modelo) async {
    try {
      // Nota que apuntamos a la misma ruta '/usuario/perfil'
      // pero el backend sabrá qué hacer porque usamos putRequest en lugar de getRequest
      await putRequest('/usuario/perfil', modelo.toJson());
    } catch (e) {
      print("Error al actualizar el perfil: $e");
      rethrow;
    }
  }



}
