class UsuarioRegistroModel {
  final String nombreCompleto;
  final String correo;
  final String telefono;
  final String contrasena;

  UsuarioRegistroModel({
    required this.nombreCompleto,
    required this.correo,
    required this.telefono,
    required this.contrasena,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombreCompleto': nombreCompleto,
      'correo': correo,
      'telefono': telefono,
      'contrasena': contrasena,
    };
  }
}