import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecigest/domain/models/community_model.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<CommunityModel> createCommunity({
    required String name,
    required String address,
    required String contactEmail,
    required String createdBy,
  }) async {
    final docRef = await _firestore.collection('communities').add({
      'name': name,
      'address': address,
      'contactEmail': contactEmail,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
    final doc = await docRef.get();
    return CommunityModel.fromFirestore(doc);
  }
}
