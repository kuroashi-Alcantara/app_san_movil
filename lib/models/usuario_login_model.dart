class UsuarioLoginModel {
  final String correo;
  final String contrasena;

  UsuarioLoginModel({
    required this.correo,
    required this.contrasena,
  });

  Map<String, dynamic> toJson() {
    return {
      'correo': correo,
      'contrasena': contrasena,
    };
  }
}
