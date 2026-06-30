class EvaluarTransaccionModel {
  final int estado; // 2 para Aprobado, 3 para Rechazado

  EvaluarTransaccionModel({
    required this.estado,
  });

  Map<String, dynamic> toJson() {
    return {
      'estado': estado,
    };
  }
}