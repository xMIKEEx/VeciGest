import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoleService {
  final _users = FirebaseFirestore.instance.collection('users');
  final _communities = FirebaseFirestore.instance.collection('communities');

  Future<bool> validateCommunityId(String id) async {
    final doc = await _communities.doc(id).get();
    return doc.exists;
  }

  Future<void> registerAdmin({
    required String email,
    required String password,
    required Map<String, dynamic> communityData,
    required Map<String, dynamic> adminData,
  }) async {
    final userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final communityRef = await _communities.add({
      ...communityData,
      'adminId': userCred.user!.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _users.doc(userCred.user!.uid).set({
      ...adminData,
      'role': 'admin',
      'communityId': communityRef.id,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> registerUser({
    required String email,
    required String password,
    required String communityId,
    required Map<String, dynamic> userData,
  }) async {
    final userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _users.doc(userCred.user!.uid).set({
      ...userData,
      'role': 'user',
      'communityId': communityId,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String?> getUserRole(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc.data()?['role'] as String?;
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc.data();
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update(data);
  }

  Future<Map<String, dynamic>?> getCommunityById(String id) async {
    final doc = await _communities.doc(id).get();
    return doc.exists ? doc.data() : null;
  }
}
