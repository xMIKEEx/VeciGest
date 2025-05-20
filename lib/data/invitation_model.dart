import 'package:cloud_firestore/cloud_firestore.dart';

class Invitation {
  final String id;
  final String email;
  final String unidadId;
  final String comunidadId;
  final String token;
  final DateTime expiracion;
  final String estado; // 'pendiente', 'aceptada', 'expirada'

  Invitation({
    required this.id,
    required this.email,
    required this.unidadId,
    required this.comunidadId,
    required this.token,
    required this.expiracion,
    required this.estado,
  });

  factory Invitation.fromMap(String id, Map<String, dynamic> map) {
    return Invitation(
      id: id,
      email: map['email'] ?? '',
      unidadId: map['unidadId'] ?? '',
      comunidadId: map['comunidadId'] ?? '',
      token: map['token'] ?? '',
      expiracion:
          (map['expiracion'] is Timestamp)
              ? (map['expiracion'] as Timestamp).toDate()
              : DateTime.tryParse(map['expiracion'].toString()) ??
                  DateTime.now(),
      estado: map['estado'] ?? 'pendiente',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'unidadId': unidadId,
      'comunidadId': comunidadId,
      'token': token,
      'expiracion': expiracion,
      'estado': estado,
    };
  }
}
