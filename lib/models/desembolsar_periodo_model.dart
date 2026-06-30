class DesembolsarPeriodoModel {
  final String urlComprobante;

  DesembolsarPeriodoModel({
    required this.urlComprobante,
  });

  // Convertimos el modelo a JSON para enviarlo al servidor en el POST
  Map<String, dynamic> toJson() {
    return {
      'urlComprobante': urlComprobante,
    };
  }
}