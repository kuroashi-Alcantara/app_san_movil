class ResultadoSorteoModel {
  final String nombreParticipante;
  final int numeroTurno;

  ResultadoSorteoModel({
    required this.nombreParticipante,
    required this.numeroTurno,
  });

  factory ResultadoSorteoModel.fromJson(Map<String, dynamic> json) {
    return ResultadoSorteoModel(
      nombreParticipante: json['nombreParticipante'],
      numeroTurno: json['numeroTurno'],
    );
  }
}