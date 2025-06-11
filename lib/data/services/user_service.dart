import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> createAdminUser({
    required String uid,
    required String email,
    required String displayName,
    required String communityId,
    String? fullName,
    String? housing,
    String? phone,
  }) async {
    // Debug: Verificar los datos antes de guardar
    print('DEBUG UserService - fullName: "$fullName"');
    print('DEBUG UserService - housing: "$housing"');
    print('DEBUG UserService - housing type: ${housing.runtimeType}');
    print('DEBUG UserService - housing will be saved as: "${housing ?? ""}"');

    final housingValue = housing ?? "";
    print('DEBUG UserService - final housingValue: "$housingValue"');
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'fullName': fullName ?? displayName,
      'housing': housingValue, // Usar la variable local para mayor claridad
      'phone': phone,
      'role': 'admin',
      'communityId': communityId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createUserByRole({
    required String uid,
    required String email,
    required String displayName,
    required String communityId,
    required String role,
    String? viviendaId,
    String? fullName,
    String? housing,
    String? phone,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'fullName': fullName ?? displayName,
      'housing':
          housing ?? viviendaId ?? "", // Guardar cadena vacía en lugar de null
      'phone': phone,
      'role': role,
      'communityId': communityId,
      'viviendaId': viviendaId ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
