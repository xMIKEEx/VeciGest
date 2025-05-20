import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/invitation_model.dart';

class InvitationService {
  final _db = FirebaseFirestore.instance;

  Future<Invitation?> getInvitationByToken(String token) async {
    final query =
        await _db
            .collection('invitations')
            .where('token', isEqualTo: token)
            .get();
    if (query.docs.isEmpty) return null;
    return Invitation.fromMap(query.docs.first.id, query.docs.first.data());
  }

  Future<void> acceptInvitation(String invitationId) async {
    await _db.collection('invitations').doc(invitationId).update({
      'estado': 'aceptada',
    });
  }
}
