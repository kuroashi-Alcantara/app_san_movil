import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/usuario_respuesta_model.dart';
import '../models/usuario_actualizar_model.dart';
import '../models/usuario_registro_model.dart';
import '../models/verificar_correo_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/sala_respuesta_model.dart';

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

  //METODOS USUARIOS

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

  // Método 1: Actualizar Datos Básicos
Future<Map<String, dynamic>> actualizarPerfil(String nombre, String telefono) async {
  try {
    // Usamos tu método genérico. ¡Dio se encarga del jsonEncode y del Token automáticamente!
    final response = await putRequest(
      '/usuario/perfil', 
      {
        'NombreCompleto': nombre, // La mayúscula vital para C#
        'Telefono': telefono,
      }
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      // Actualizamos la bóveda para el menú lateral
      final storage = const FlutterSecureStorage();
      await storage.write(key: 'nombre_usuario', value: nombre);
      
      return {'success': true, 'mensaje': 'Perfil actualizado con éxito'};
    } else {
      return {'success': false, 'mensaje': 'Error al actualizar'};
    }
  } catch (e) {
    // Con Dio, si el servidor devuelve un error (ej. 400 o 401), cae directamente aquí (DioException)
    print('🚨 ERROR DIO: $e');
    return {'success': false, 'mensaje': 'No se pudo actualizar el perfil'};
  }
}

// Método 2: Cambiar Contraseña
Future<Map<String, dynamic>> cambiarContrasena(String actual, String nueva) async {
  try {
    // Usamos tu método genérico de Dio. ¡Él pone el Token y el jsonEncode!
    final response = await putRequest(
      '/usuario/cambiar-contrasena',
      {
        'ContrasenaActual': actual, // Mayúscula inicial para C#
        'NuevaContrasena': nueva,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return {'success': true, 'mensaje': 'Contraseña cambiada con éxito'};
    } else {
      return {'success': false, 'mensaje': 'Error al cambiar la contraseña'};
    }
  } catch (e) {
    print('🚨 ERROR AL CAMBIAR CONTRASEÑA: $e');
    // Si la contraseña actual es incorrecta, C# suele mandar un 400 BadRequest 
    // y cae directamente en este catch gracias a Dio.
    return {'success': false, 'mensaje': 'Verifica que tu contraseña actual sea correcta'};
  }
}

// ==========================================
//          MÉTODOS PARA SALAS
// ==========================================

// 1. Crear una nueva sala
Future<Map<String, dynamic>> crearSala(Map<String, dynamic> salaData) async {
  try {
    // Recuerda que al llamar este método desde la UI, salaData debe ir 
    // con las llaves en PascalCase: {'NombreSala': 'Mi Sala', 'MontoCuota': 1000, ...}
    final response = await postRequest('/Salas', salaData);
    
    // 200 (OK) o 201 (Created)
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, 'mensaje': 'Sala creada exitosamente'};
    } else {
      return {'success': false, 'mensaje': 'Error al crear la sala'};
    }
  } catch (e) {
    print('🚨 ERROR AL CREAR SALA: $e');
    return {'success': false, 'mensaje': 'Verifica los datos de la sala'};
  }
}

// 2. Obtener las salas que yo administro (Soy el creador)
Future<List<SalaRespuestaModel>> obtenerSalasAdministradas() async {
  try {
    // Asegúrate de que esta ruta coincida con la de tu SalaController
    final response = await getRequest('/Salas/administradas'); 
    
    if (response.statusCode == 200) {
      // Dio devuelve el JSON ya decodificado en response.data
      List<dynamic> data = response.data;
      return data.map((json) => SalaRespuestaModel.fromJson(json)).toList();
    }
    return [];
  } catch (e) {
    print('🚨 ERROR OBTENER SALAS ADMINISTRADAS: $e');
    return [];
  }
}

Future<Map<String, dynamic>?> obtenerDetalleSala(String idSala) async {
    try {
      final response = await getRequest('/Salas/$idSala');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('🚨 ERROR GET DETALLE SALA: $e');
      return null;
    }
  }

// 3. Obtener las salas en las que solo participo (El código de invitación)
Future<List<SalaRespuestaModel>> obtenerSalasParticipadas() async {
  try {
    final response = await getRequest('/Salas/participadas');
    
    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      return data.map((json) => SalaRespuestaModel.fromJson(json)).toList();
    }
    return [];
  } catch (e) {
    print('🚨 ERROR OBTENER SALAS PARTICIPADAS: $e');
    return [];
  }
}

// 4. Actualizar una sala existente
Future<Map<String, dynamic>> actualizarSala(String salaId, Map<String, dynamic> salaActualizada) async {
  try {
    final response = await putRequest('/Salas/$salaId', salaActualizada);
    
    if (response.statusCode == 200 || response.statusCode == 204) {
      return {'success': true, 'mensaje': 'Sala actualizada correctamente'};
    } else {
      return {'success': false, 'mensaje': 'Error al actualizar la sala'};
    }
  } catch (e) {
    print('🚨 ERROR ACTUALIZAR SALA: $e');
    return {'success': false, 'mensaje': 'No se pudo actualizar la sala'};
  }
}

// 5. Unirse a una sala usando el código
  Future<Map<String, dynamic>> unirseASala(String codigoSala) async {
    try {
      // Mandamos un body vacío {} porque el dato viaja en la URL
      final response = await postRequest('/Salas/unirse/$codigoSala', {});
      
      if (response.statusCode == 200) {
        return {'success': true, 'mensaje': '¡Te has unido a la sala con éxito!'};
      } else {
        return {'success': false, 'mensaje': 'Error al intentar unirse a la sala'};
      }
    } catch (e) {
      print('🚨 ERROR AL UNIRSE A SALA: $e');
      // Gracias a Dio, si C# responde un 400 (Ya estás en la sala) o 404 (No existe), caerá aquí
      return {'success': false, 'mensaje': 'Verifica el código o puede que ya seas participante.'};
    }
  }


}
