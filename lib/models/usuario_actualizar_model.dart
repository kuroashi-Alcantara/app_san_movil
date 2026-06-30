class UsuarioActualizarModel {
  final String nombreCompleto;
  final String correo;
  final String telefono;

  UsuarioActualizarModel({
    required this.nombreCompleto,
    required this.correo,
    required this.telefono,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombreCompleto': nombreCompleto,
      'correo': correo,
      'telefono': telefono,
    };
  }
}