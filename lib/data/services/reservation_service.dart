import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecigest/domain/models/reservation_model.dart';

class ReservationService {
  final CollectionReference reservations = FirebaseFirestore.instance
      .collection('reservations');
  Stream<List<Reservation>> getReservations() {
    return reservations.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => Reservation.fromFirestore(doc)).toList(),
    );
  }

  Stream<List<Reservation>> getReservationsByCommunity(String communityId) {
    return reservations
        .where('communityId', isEqualTo: communityId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Reservation.fromFirestore(doc))
                  .toList(),
        );
  }

  // Get only user reservations (excluding admin events)
  Stream<List<Reservation>> getUserReservations() {
    return reservations
        .where('userId', isNotEqualTo: 'admin')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Reservation.fromFirestore(doc))
                  .toList(),
        );
  }

  Future<void> addReservation(Reservation reservation) async {
    await reservations.add(reservation.toMap());
  }

  Future<void> deleteReservation(String id) async {
    await reservations.doc(id).delete();
  }

  Future<List<String>> getAvailableResources(String communityId) async {
    // Obtener los recursos de la comunidad desde Firestore
    final communityDoc =
        await FirebaseFirestore.instance
            .collection('communities')
            .doc(communityId)
            .get();

    if (communityDoc.exists) {
      final data = communityDoc.data() as Map<String, dynamic>;
      return List<String>.from(data['resources'] ?? []);
    }

    return [];
  }
}
