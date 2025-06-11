import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecigest/domain/models/community_model.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<CommunityModel> createCommunity({
    required String name,
    required String address,
    required String contactEmail,
    required String createdBy,
    List<String> resources = const [],
  }) async {
    final docRef = await _firestore.collection('communities').add({
      'name': name,
      'address': address,
      'contactEmail': contactEmail,
      'createdBy': createdBy,
      'resources': resources,
      'createdAt': FieldValue.serverTimestamp(),
    });
    final doc = await docRef.get();
    return CommunityModel.fromFirestore(doc);
  }

  Future<CommunityModel?> getCommunityById(String id) async {
    final doc = await _firestore.collection('communities').doc(id).get();
    if (!doc.exists) return null;
    return CommunityModel.fromFirestore(doc);
  }

  Future<void> updateCommunity({
    required String id,
    required String name,
    required String address,
    required String contactEmail,
    List<String>? resources,
  }) async {
    final updateData = <String, dynamic>{
      'name': name,
      'address': address,
      'contactEmail': contactEmail,
    };

    if (resources != null) {
      updateData['resources'] = resources;
    }

    await _firestore.collection('communities').doc(id).update(updateData);
  }
}
