import 'package:cloud_firestore/cloud_firestore.dart';

class UserRoleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<Map<String, dynamic>?> getUserRoleAndCommunity(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return {
      'role': data['role'] ?? 'user',
      'communityId': data['communityId'] ?? '',
      'viviendaId': data['viviendaId'] ?? '', // Añadido para login correcto
    };
  }

  // Método para verificar si un usuario tiene comunidad asociada
  Future<bool> userHasCommunity(String uid) async {
    final userRole = await getUserRoleAndCommunity(uid);
    if (userRole == null) return false;
    return userRole['communityId'] != null &&
        userRole['communityId'].isNotEmpty;
  }
}
