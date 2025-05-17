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

  Future<void> addReservation(Reservation reservation) async {
    await reservations.add(reservation.toMap());
  }

  Future<void> deleteReservation(String id) async {
    await reservations.doc(id).delete();
  }
}
