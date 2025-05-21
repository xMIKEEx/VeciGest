import 'package:cloud_firestore/cloud_firestore.dart';

class InviteModel {
  final String id;
  final String communityId;
  final String email;
  final String role; // 'user' o 'admin'
  final String vivienda;
  final String token;
  final DateTime expiresAt;
  final bool used;

  InviteModel({
    required this.id,
    required this.communityId,
    required this.email,
    required this.role,
    required this.vivienda,
    required this.token,
    required this.expiresAt,
    required this.used,
  });

  factory InviteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InviteModel(
      id: doc.id,
      communityId: data['communityId'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      vivienda: data['vivienda'] ?? '',
      token: data['token'] ?? '',
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      used: data['used'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'communityId': communityId,
      'email': email,
      'role': role,
      'vivienda': vivienda,
      'token': token,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'used': used,
    };
  }
}
