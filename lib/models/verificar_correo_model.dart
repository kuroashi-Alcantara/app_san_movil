class VerificarCorreoModel {
  final String correo;
  final String codigo;

  VerificarCorreoModel({
    required this.correo,
    required this.codigo,
  });

  Map<String, dynamic> toJson() {
    return {
      'correo': correo,
      'codigo': codigo,
    };
  }
}