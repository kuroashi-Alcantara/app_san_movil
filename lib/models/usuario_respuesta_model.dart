class UsuarioRespuestaModel {
  final String id;
  final String nombreCompleto;
  final String correo;
  final String telefono;

  UsuarioRespuestaModel({
    required this.id,
    required this.nombreCompleto,
    required this.correo,
    required this.telefono,
  });

  factory UsuarioRespuestaModel.fromJson(Map<String, dynamic> json) {
    return UsuarioRespuestaModel(
      id: json['id'],
      nombreCompleto: json['nombreCompleto'],
      correo: json['correo'],
      telefono: json['telefono'],
    );
  }
}