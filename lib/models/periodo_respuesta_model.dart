class PeriodoRespuestaModel {
  final String id;
  final String salaId;
  final int numeroRonda;
  final DateTime fechaVencimiento;
  final String beneficiarioId;
  final String beneficiarioNombre;
  final int estadoPeriodo; // 1: Pendiente, 2: Completado, 3: Atrasado
  final DateTime? fechaDesembolso;

  PeriodoRespuestaModel({
    required this.id,
    required this.salaId,
    required this.numeroRonda,
    required this.fechaVencimiento,
    required this.beneficiarioId,
    required this.beneficiarioNombre,
    required this.estadoPeriodo,
    this.fechaDesembolso,
  });

  // Fábrica para convertir el JSON que llega de la API a nuestro objeto Dart
  factory PeriodoRespuestaModel.fromJson(Map<String, dynamic> json) {
    return PeriodoRespuestaModel(
      id: json['id'] ?? '',
      salaId: json['salaId'] ?? '',
      numeroRonda: json['numeroRonda'] ?? 0,
      fechaVencimiento: DateTime.parse(json['fechaVencimiento']),
      beneficiarioId: json['beneficiarioId'] ?? '',
      beneficiarioNombre: json['beneficiarioNombre'] ?? 'Desconocido',
      estadoPeriodo: json['estadoPeriodo'] ?? 1,
      // Como la fecha de desembolso puede ser nula, la validamos antes de parsear
      fechaDesembolso: json['fechaDesembolso'] != null 
          ? DateTime.parse(json['fechaDesembolso']) 
          : null,
    );
  }

  // Método opcional por si en algún momento necesitas enviarlo de vuelta al servidor
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salaId': salaId,
      'numeroRonda': numeroRonda,
      'fechaVencimiento': fechaVencimiento.toIso8601String(),
      'beneficiarioId': beneficiarioId,
      'beneficiarioNombre': beneficiarioNombre,
      'estadoPeriodo': estadoPeriodo,
      'fechaDesembolso': fechaDesembolso?.toIso8601String(),
    };
  }
}