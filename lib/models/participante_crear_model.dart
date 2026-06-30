class ParticipanteCrearModel {
  final String salaId;
  final String usuarioId;
  final int numeroTurno;

  ParticipanteCrearModel({
    required this.salaId,
    required this.usuarioId,
    required this.numeroTurno,
  });

  Map<String, dynamic> toJson() {
    return {
      'salaId': salaId,
      'usuarioId': usuarioId,
      'numeroTurno': numeroTurno,
    };
  }
}