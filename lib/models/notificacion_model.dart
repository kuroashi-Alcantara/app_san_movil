class NotificacionModel {
  final String id;
  final String titulo;
  final String mensaje;
  final bool leida;
  final DateTime fechaCreacion;

  NotificacionModel({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.leida,
    required this.fechaCreacion,
  });

  factory NotificacionModel.fromJson(Map<String, dynamic> json) {
    return NotificacionModel(
      id: json['id'],
      titulo: json['titulo'],
      mensaje: json['mensaje'],
      leida: json['leida'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }
}