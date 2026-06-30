class DashboardParticipanteModel {
  final List<SalaResumenModel> misSalas;
  final List<PagoPendienteModel> pagosPendientes;
  final List<CobroProximoModel> proximosCobros;

  DashboardParticipanteModel({
    required this.misSalas,
    required this.pagosPendientes,
    required this.proximosCobros,
  });

  factory DashboardParticipanteModel.fromJson(Map<String, dynamic> json) {
    return DashboardParticipanteModel(
      misSalas: (json['misSalas'] as List)
          .map((i) => SalaResumenModel.fromJson(i)).toList(),
      pagosPendientes: (json['pagosPendientes'] as List)
          .map((i) => PagoPendienteModel.fromJson(i)).toList(),
      proximosCobros: (json['proximosCobros'] as List)
          .map((i) => CobroProximoModel.fromJson(i)).toList(),
    );
  }
}

class SalaResumenModel {
  final String salaId;
  final String nombreSala;
  final double montoCuota;
  final String frecuencia;
  final int miTurno;

  SalaResumenModel({required this.salaId, required this.nombreSala, required this.montoCuota, required this.frecuencia, required this.miTurno});

  factory SalaResumenModel.fromJson(Map<String, dynamic> json) {
    return SalaResumenModel(
      salaId: json['salaId'],
      nombreSala: json['nombreSala'],
      montoCuota: (json['montoCuota'] as num).toDouble(),
      frecuencia: json['frecuencia'],
      miTurno: json['miTurno'],
    );
  }
}

class PagoPendienteModel {
  final String periodoId;
  final String nombreSala;
  final int numeroRonda;
  final double montoAPagar;
  final DateTime fechaVencimiento;

  PagoPendienteModel({required this.periodoId, required this.nombreSala, required this.numeroRonda, required this.montoAPagar, required this.fechaVencimiento});

  factory PagoPendienteModel.fromJson(Map<String, dynamic> json) {
    return PagoPendienteModel(
      periodoId: json['periodoId'],
      nombreSala: json['nombreSala'],
      numeroRonda: json['numeroRonda'],
      montoAPagar: (json['montoAPagar'] as num).toDouble(),
      fechaVencimiento: DateTime.parse(json['fechaVencimiento']),
    );
  }
}

class CobroProximoModel {
  final String periodoId;
  final String nombreSala;
  final int numeroRonda;
  final double montoEstimado;
  final DateTime fechaCobro;

  CobroProximoModel({required this.periodoId, required this.nombreSala, required this.numeroRonda, required this.montoEstimado, required this.fechaCobro});

  factory CobroProximoModel.fromJson(Map<String, dynamic> json) {
    return CobroProximoModel(
      periodoId: json['periodoId'],
      nombreSala: json['nombreSala'],
      numeroRonda: json['numeroRonda'],
      montoEstimado: (json['montoEstimado'] as num).toDouble(),
      fechaCobro: DateTime.parse(json['fechaCobro']),
    );
  }
}