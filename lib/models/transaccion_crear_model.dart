import 'dart:io';

class TransaccionCrearModel {
  final String periodoId;
  final String usuarioPagadorId;
  final double monto;
  final File imagenVoucher; // El archivo físico en el dispositivo

  TransaccionCrearModel({
    required this.periodoId,
    required this.usuarioPagadorId,
    required this.monto,
    required this.imagenVoucher,
  });

  // Este modelo no necesita un toJson() tradicional,
  // usaremos FormData en el ApiClient para este caso.
}