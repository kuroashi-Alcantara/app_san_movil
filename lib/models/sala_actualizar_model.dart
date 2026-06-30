class SalaActualizarModel {
  final String nombreSala;
  final double montoCuota;
  final int frecuencia; // Mapeado como int (según tu Enum)
  final int cantidadParticipantes;
  final bool esPublica;
  final bool permitirMultiplesTurnos;
  final int estado; // Mapeado como int

  SalaActualizarModel({
    required this.nombreSala,
    required this.montoCuota,
    required this.frecuencia,
    required this.cantidadParticipantes,
    required this.esPublica,
    required this.permitirMultiplesTurnos,
    required this.estado,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombreSala': nombreSala,
      'montoCuota': montoCuota,
      'frecuencia': frecuencia,
      'cantidadParticipantes': cantidadParticipantes,
      'esPublica': esPublica,
      'permitirMultiplesTurnos': permitirMultiplesTurnos,
      'estado': estado,
    };
  }
}