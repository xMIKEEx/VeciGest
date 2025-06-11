import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String id;
  final String resourceName;
  final String userId;
  final String communityId;
  final DateTime startTime;
  final DateTime endTime;

  Reservation({
    required this.id,
    required this.resourceName,
    required this.userId,
    required this.communityId,
    required this.startTime,
    required this.endTime,
  });
  factory Reservation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reservation(
      id: doc.id,
      resourceName: data['resourceName'] ?? '',
      userId: data['userId'] ?? '',
      communityId: data['communityId'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'resourceName': resourceName,
      'userId': userId,
      'communityId': communityId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
    };
  }

  // Nueva función: duración de la reserva en minutos
  int get durationMinutes => endTime.difference(startTime).inMinutes;

  // Nueva función: formato amigable de fecha y hora
  String get formattedRange =>
      '${_formatDate(startTime)} ${_formatTime(startTime)} - ${_formatDate(endTime)} ${_formatTime(endTime)}';

  static String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  static String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
