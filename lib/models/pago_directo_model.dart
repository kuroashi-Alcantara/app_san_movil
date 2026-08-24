class PagoDirectoModel {
  final String periodoId;
  final String usuarioPagadorId;
  final double monto;

  PagoDirectoModel({
    required this.periodoId,
    required this.usuarioPagadorId,
    required this.monto,
  });

  // Método vital para convertir nuestro objeto a JSON antes de enviarlo a C#
  Map<String, dynamic> toJson() {
    return {
      'periodoId': periodoId,
      'usuarioPagadorId': usuarioPagadorId,
      'monto': monto,
    };
  }
}