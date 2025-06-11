import 'package:cloud_firestore/cloud_firestore.dart';

class ResourceModel {
  final String id;
  final String name;
  final String description;
  final String communityId;
  final DateTime createdAt;

  ResourceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.communityId,
    required this.createdAt,
  });

  factory ResourceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ResourceModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      communityId: data['communityId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  factory ResourceModel.fromMap(Map<String, dynamic> data, String id) {
    return ResourceModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      communityId: data['communityId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'communityId': communityId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
