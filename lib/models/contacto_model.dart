class ContactoModel {
  final String id; // El Guid de C# se maneja como String en Dart
  final String nombre;
  final String telefono;
  final String email;

  ContactoModel({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.email,
  });

  factory ContactoModel.fromJson(Map<String, dynamic> json) {
    return ContactoModel(
      id: json['id'],
      nombre: json['nombre'],
      telefono: json['telefono'],
      email: json['email'],
    );
  }
}