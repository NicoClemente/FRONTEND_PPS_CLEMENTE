class UserModel {
  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final String? telefono;

  UserModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.telefono,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    nombre: json['nombre'],
    apellido: json['apellido'],
    email: json['email'],
    telefono: json['telefono'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'apellido': apellido,
    'email': email,
    if (telefono != null) 'telefono': telefono,
  };
}