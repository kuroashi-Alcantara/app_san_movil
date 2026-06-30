class PeriodoRespuestaModel {
  final String id;
  final String salaId;
  final int numeroRonda;
  final DateTime fechaVencimiento;
  final String beneficiarioId;
  final int estadoPeriodo; // Enum mapeado como entero
  final String urlComprobanteDesembolso;
  final DateTime? fechaDesembolso; // Puede ser nulo

  PeriodoRespuestaModel({
    required this.id,
    required this.salaId,
    required this.numeroRonda,
    required this.fechaVencimiento,
    required this.beneficiarioId,
    required this.estadoPeriodo,
    required this.urlComprobanteDesembolso,
    this.fechaDesembolso,
  });

  factory PeriodoRespuestaModel.fromJson(Map<String, dynamic> json) {
    return PeriodoRespuestaModel(
      id: json['id'],
      salaId: json['salaId'],
      numeroRonda: json['numeroRonda'],
      fechaVencimiento: DateTime.parse(json['fechaVencimiento']),
      beneficiarioId: json['beneficiarioId'],
      estadoPeriodo: json['estadoPeriodo'],
      urlComprobanteDesembolso: json['urlComprobanteDesembolso'] ?? '',
      fechaDesembolso: json['fechaDesembolso'] != null 
          ? DateTime.parse(json['fechaDesembolso']) 
          : null,
    );
  }
}