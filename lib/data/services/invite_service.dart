import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecigest/domain/models/invite_model.dart';
import 'package:vecigest/data/services/property_service.dart';

class InviteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PropertyService _propertyService = PropertyService();

  String _generateToken([int length = 32]) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure();
    return List.generate(
      length,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  Future<InviteModel> createInvite({
    required String communityId,
    required String email,
    required String role,
    required String vivienda,
    int daysValid = 7,
  }) async {
    final token = _generateToken();
    final expiresAt = DateTime.now().add(Duration(days: daysValid));
    final docRef = await _firestore.collection('invites').add({
      'communityId': communityId,
      'email': email,
      'role': role,
      'vivienda': vivienda,
      'token': token,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'used': false,
    });
    final doc = await docRef.get();
    return InviteModel.fromFirestore(doc);
  }

  Future<InviteModel?> getInviteByToken(String token) async {
    final snap =
        await _firestore
            .collection('invites')
            .where('token', isEqualTo: token)
            .limit(1)
            .get();
    if (snap.docs.isEmpty) return null;
    return InviteModel.fromFirestore(snap.docs.first);
  }

  Future<void> markInviteUsed(String inviteId, String userId) async {
    // Get the invite to check if it has a property
    final inviteDoc =
        await _firestore.collection('invites').doc(inviteId).get();
    final invite = InviteModel.fromFirestore(inviteDoc);

    // If there's a property assigned and the role is 'user', assign the user to the property
    if (invite.vivienda.isNotEmpty && invite.role == 'user') {
      try {
        await _propertyService.assignUserToProperty(invite.vivienda, userId);
      } catch (e) {
        // No marcar como usada si hay error de asignación
        rethrow;
      }
      // Remove the pending invitation flag
      await _propertyService.updateProperty(invite.vivienda, {
        'invitePending': false,
      });
    }

    // Mark the invite as used
    await _firestore.collection('invites').doc(inviteId).update({'used': true});
  }

  // Método para obtener todas las invitaciones activas
  Stream<List<InviteModel>> getActiveInvites(String communityId) {
    return _firestore
        .collection('invites')
        .where('communityId', isEqualTo: communityId)
        .where('used', isEqualTo: false)
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => InviteModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // Método para cancelar una invitación
  Future<void> cancelInvite(String inviteId) async {
    // Get the invite to check if it has a property
    final inviteDoc =
        await _firestore.collection('invites').doc(inviteId).get();
    final invite = InviteModel.fromFirestore(inviteDoc);

    // If there's a property assigned, remove the pending flag
    if (invite.vivienda.isNotEmpty && invite.role == 'user') {
      await _propertyService.updateProperty(invite.vivienda, {
        'invitePending': false,
      });
    }

    // Delete the invite
    await _firestore.collection('invites').doc(inviteId).delete();
  }
}
