class SalaCrearModel {
  final String nombreSala;
  final double montoCuota;
  final int frecuencia; // 1: Semanal, 2: Quincenal, 3: Mensual
  final int cantidadParticipantes;
  final bool esPublica;
  final bool permitirMultiplesTurnos;
  final DateTime fechaInicio;

  SalaCrearModel({
    required this.nombreSala,
    required this.montoCuota,
    required this.frecuencia,
    required this.cantidadParticipantes,
    required this.esPublica,
    required this.permitirMultiplesTurnos,
    required this.fechaInicio,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombreSala': nombreSala,
      'montoCuota': montoCuota,
      'frecuencia': frecuencia,
      'cantidadParticipantes': cantidadParticipantes,
      'esPublica': esPublica,
      'permitirMultiplesTurnos': permitirMultiplesTurnos,
      'fechaInicio': fechaInicio.toIso8601String(), // Formato estándar para C#
    };
  }
}