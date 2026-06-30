class SalaRespuestaModel {
  final String id;
  final String creadorId;
  final String nombreSala;
  final double montoCuota;
  final int frecuencia; // Enum
  final int cantidadParticipantes;
  final bool esPublica;
  final bool permitirMultiplesTurnos;
  final int estado; // Enum
  final DateTime fechaInicio;
  final DateTime fechaCreacion;

  SalaRespuestaModel({
    required this.id,
    required this.creadorId,
    required this.nombreSala,
    required this.montoCuota,
    required this.frecuencia,
    required this.cantidadParticipantes,
    required this.esPublica,
    required this.permitirMultiplesTurnos,
    required this.estado,
    required this.fechaInicio,
    required this.fechaCreacion,
  });

  factory SalaRespuestaModel.fromJson(Map<String, dynamic> json) {
    return SalaRespuestaModel(
      id: json['id'],
      creadorId: json['creadorId'],
      nombreSala: json['nombreSala'],
      montoCuota: (json['montoCuota'] as num).toDouble(),
      frecuencia: json['frecuencia'],
      cantidadParticipantes: json['cantidadParticipantes'],
      esPublica: json['esPublica'],
      permitirMultiplesTurnos: json['permitirMultiplesTurnos'],
      estado: json['estado'],
      fechaInicio: DateTime.parse(json['fechaInicio']),
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }
}