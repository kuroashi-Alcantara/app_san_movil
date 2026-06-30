class TransaccionRespuestaModel {
  final String id;
  final String periodoId;
  final String usuarioPagadorId;
  final double monto;
  final String urlVoucher;
  final int estadoPago; // Enum mapeado como entero

  TransaccionRespuestaModel({
    required this.id,
    required this.periodoId,
    required this.usuarioPagadorId,
    required this.monto,
    required this.urlVoucher,
    required this.estadoPago,
  });

  factory TransaccionRespuestaModel.fromJson(Map<String, dynamic> json) {
    return TransaccionRespuestaModel(
      id: json['id'],
      periodoId: json['periodoId'],
      usuarioPagadorId: json['usuarioPagadorId'],
      monto: (json['monto'] as num).toDouble(),
      urlVoucher: json['urlVoucher'],
      estadoPago: json['estadoPago'],
    );
  }
}