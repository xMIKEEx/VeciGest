import 'package:cloud_firestore/cloud_firestore.dart';

class InviteModel {
  final String id;
  final String communityId;
  final String role; // 'resident' o 'admin'
  final String viviendaId;
  final String token;
  final bool used;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final String? usedBy;

  InviteModel({
    required this.id,
    required this.communityId,
    required this.role,
    required this.viviendaId,
    required this.token,
    required this.used,
    this.createdAt,
    this.expiresAt,
    this.usedBy,
  });

  factory InviteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InviteModel(
      id: doc.id,
      communityId: data['communityId'] ?? '',
      role: data['role'] ?? 'resident',
      viviendaId: data['viviendaId'] ?? '',
      token: data['token'] ?? '',
      used: data['used'] ?? false,
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : null,
      expiresAt:
          data['expiresAt'] != null
              ? (data['expiresAt'] as Timestamp).toDate()
              : null,
      usedBy: data['usedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'communityId': communityId,
      'role': role,
      'viviendaId': viviendaId,
      'token': token,
      'used': used,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'usedBy': usedBy,
    };
  }
}
