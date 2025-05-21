import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityModel {
  final String id;
  final String name;
  final String address;
  final String contactEmail;
  final DateTime createdAt;

  CommunityModel({
    required this.id,
    required this.name,
    required this.address,
    required this.contactEmail,
    required this.createdAt,
  });

  factory CommunityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityModel(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      contactEmail: data['contactEmail'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'contactEmail': contactEmail,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
