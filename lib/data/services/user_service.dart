import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createAdminUser({
    required String uid,
    required String email,
    required String displayName,
    required String communityId,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'displayName': displayName,
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
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'communityId': communityId,
      'viviendaId': viviendaId ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
