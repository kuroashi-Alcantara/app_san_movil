class AdminDashboardModel {
  final List<SalaAdministradaModel> misSalasOrganizadas;
  final List<VoucherPendienteModel> vouchersPorRevisar;
  final List<DesembolsoPendienteModel> desembolsosPorHacer;

  AdminDashboardModel({
    required this.misSalasOrganizadas,
    required this.vouchersPorRevisar,
    required this.desembolsosPorHacer,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardModel(
      misSalasOrganizadas: (json['misSalasOrganizadas'] as List)
          .map((i) => SalaAdministradaModel.fromJson(i)).toList(),
      vouchersPorRevisar: (json['vouchersPorRevisar'] as List)
          .map((i) => VoucherPendienteModel.fromJson(i)).toList(),
      desembolsosPorHacer: (json['desembolsosPorHacer'] as List)
          .map((i) => DesembolsoPendienteModel.fromJson(i)).toList(),
    );
  }
}

class SalaAdministradaModel {
  final String salaId;
  final String nombreSala;
  final int participantesActivos;
  final String estado;

  SalaAdministradaModel({required this.salaId, required this.nombreSala, required this.participantesActivos, required this.estado});

  factory SalaAdministradaModel.fromJson(Map<String, dynamic> json) {
    return SalaAdministradaModel(
      salaId: json['salaId'],
      nombreSala: json['nombreSala'],
      participantesActivos: json['participantesActivos'],
      estado: json['estado'],
    );
  }
}

class VoucherPendienteModel {
  final String transaccionId;
  final String nombreSala;
  final int numeroRonda;
  final String nombrePagador;
  final double monto;
  final String urlVoucher;

  VoucherPendienteModel({required this.transaccionId, required this.nombreSala, required this.numeroRonda, required this.nombrePagador, required this.monto, required this.urlVoucher});

  factory VoucherPendienteModel.fromJson(Map<String, dynamic> json) {
    return VoucherPendienteModel(
      transaccionId: json['transaccionId'],
      nombreSala: json['nombreSala'],
      numeroRonda: json['numeroRonda'],
      nombrePagador: json['nombrePagador'],
      monto: (json['monto'] as num).toDouble(),
      urlVoucher: json['urlVoucher'],
    );
  }
}

class DesembolsoPendienteModel {
  final String periodoId;
  final String nombreSala;
  final int numeroRonda;
  final String nombreBeneficiario;
  final double montoTotalPozo;

  DesembolsoPendienteModel({required this.periodoId, required this.nombreSala, required this.numeroRonda, required this.nombreBeneficiario, required this.montoTotalPozo});

  factory DesembolsoPendienteModel.fromJson(Map<String, dynamic> json) {
    return DesembolsoPendienteModel(
      periodoId: json['periodoId'],
      nombreSala: json['nombreSala'],
      numeroRonda: json['numeroRonda'],
      nombreBeneficiario: json['nombreBeneficiario'],
      montoTotalPozo: (json['montoTotalPozo'] as num).toDouble(),
    );
  }
}