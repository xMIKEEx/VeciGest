import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityService {
  final _communities = FirebaseFirestore.instance.collection('communities');

  Future<bool> exists(String id) async {
    final doc = await _communities.doc(id).get();
    return doc.exists;
  }

  Future<String> createCommunity(Map<String, dynamic> data) async {
    final doc = await _communities.add(data);
    return doc.id;
  }
}
