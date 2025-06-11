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
    required String role,
    required String viviendaId,
    int daysValid = 7,
  }) async {
    final token = _generateToken();
    final now = DateTime.now();
    final expiresAt = now.add(Duration(days: daysValid));
    final docRef = await _firestore.collection('invitationTokens').add({
      'communityId': communityId,
      'role': role,
      'viviendaId': viviendaId,
      'token': token,
      'used': false,
      'createdAt': Timestamp.fromDate(now),
      'expiresAt': Timestamp.fromDate(expiresAt),
    });
    final doc = await docRef.get();
    return InviteModel.fromFirestore(doc);
  }

  Future<InviteModel?> getInviteByToken(String token) async {
    final query =
        await _firestore
            .collection('invitationTokens')
            .where('token', isEqualTo: token)
            .limit(1)
            .get();
    if (query.docs.isEmpty) return null;
    return InviteModel.fromFirestore(query.docs.first);
  }

  Future<void> markInviteUsed(String inviteId, String userId) async {
    final inviteDoc =
        await _firestore.collection('invitationTokens').doc(inviteId).get();
    final invite = InviteModel.fromFirestore(inviteDoc);

    // Primero marcar el token como usado para evitar problemas de estado
    await _firestore.collection('invitationTokens').doc(inviteId).update({
      'used': true,
      'usedBy': userId,
    });

    // Luego intentar asignar el usuario a la propiedad si es necesario
    if (invite.viviendaId.isNotEmpty && invite.role == 'resident') {
      try {
        await _propertyService.assignUserToProperty(
          invite.communityId,
          invite.viviendaId,
          userId,
        );
      } catch (e) {
        // Si ya está asignado, no es un error crítico
        // Solo registramos el error pero no lo relanzamos
        print('Info: Usuario ya asignado o error en asignación: $e');
      }
    }
  }

  // Método para obtener todas las invitaciones activas (sin filtro de expiración)
  Stream<List<InviteModel>> getActiveInvites(String communityId) {
    return _firestore
        .collection('invitationTokens')
        .where('communityId', isEqualTo: communityId)
        .where('used', isEqualTo: false)
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
        await _firestore.collection('invitationTokens').doc(inviteId).get();
    final invite = InviteModel.fromFirestore(inviteDoc);

    // If there's a property assigned, remove the pending flag
    if (invite.viviendaId.isNotEmpty && invite.role == 'resident') {
      await _propertyService.updateProperty(
        invite.communityId,
        invite.viviendaId,
        {'invitePending': false},
      );
    }

    // Delete the invite
    await _firestore.collection('invitationTokens').doc(inviteId).delete();
  }
}
