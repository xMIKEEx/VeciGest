import 'package:cloud_firestore/cloud_firestore.dart';

class Community {
  final String id;
  final String nombre;
  final String clave;
  final String adminId;
  final DateTime fechaCreacion;

  Community({
    required this.id,
    required this.nombre,
    required this.clave,
    required this.adminId,
    required this.fechaCreacion,
  });

  factory Community.fromMap(String id, Map<String, dynamic> map) {
    return Community(
      id: id,
      nombre: map['nombre'] ?? '',
      clave: map['clave'] ?? '',
      adminId: map['adminId'] ?? '',
      fechaCreacion:
          (map['fechaCreacion'] is Timestamp)
              ? (map['fechaCreacion'] as Timestamp).toDate()
              : DateTime.tryParse(map['fechaCreacion']?.toString() ?? '') ??
                  DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'clave': clave,
      'adminId': adminId,
      'fechaCreacion': fechaCreacion,
    };
  }
}
