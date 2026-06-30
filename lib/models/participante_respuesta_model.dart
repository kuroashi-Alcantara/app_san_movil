class ParticipanteRespuestaModel {
  final String id;
  final String salaId;
  final String usuarioId;
  final int numeroTurno;
  final int estadoParticipacion; // Mapeado como entero

  ParticipanteRespuestaModel({
    required this.id,
    required this.salaId,
    required this.usuarioId,
    required this.numeroTurno,
    required this.estadoParticipacion,
  });

  factory ParticipanteRespuestaModel.fromJson(Map<String, dynamic> json) {
    return ParticipanteRespuestaModel(
      id: json['id'],
      salaId: json['salaId'],
      usuarioId: json['usuarioId'],
      numeroTurno: json['numeroTurno'],
      estadoParticipacion: json['estadoParticipacion'],
    );
  }
}
