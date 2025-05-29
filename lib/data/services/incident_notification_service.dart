import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vecigest/domain/models/incident_notification_model.dart';
import 'package:vecigest/data/services/user_role_service.dart';

class IncidentNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserRoleService _userRoleService = UserRoleService();
  // Crear una notificación de incidencia
  Future<void> createIncidentNotification({
    required String incidentId,
    required String incidentTitle,
    required String type,
    required String message,
    String? oldValue,
    String? newValue,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Obtener el ID de la comunidad del usuario actual
      final userRole = await _userRoleService.getUserRoleAndCommunity(user.uid);
      final communityId = userRole?['communityId'] as String? ?? '';

      // Si no hay comunidad, no crear la notificación
      if (communityId.isEmpty) return;

      final notification = IncidentNotification(
        id: _firestore.collection('incident_notifications').doc().id,
        incidentId: incidentId,
        incidentTitle: incidentTitle,
        type: type,
        message: message,
        oldValue: oldValue,
        newValue: newValue,
        timestamp: DateTime.now(),
        userId: user.uid,
        userEmail: user.email ?? '',
        communityId: communityId, // Añadimos el ID de la comunidad
      );

      await _firestore
          .collection('incident_notifications')
          .doc(notification.id)
          .set(notification.toMap());
    } catch (e) {
      print('Error creating incident notification: $e');
    }
  }

  // Obtener todas las notificaciones de incidencias ordenadas por fecha
  Stream<List<IncidentNotification>> getIncidentNotifications() {
    return _firestore
        .collection('incident_notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => IncidentNotification.fromMap(doc.data()))
                  .toList(),
        );
  }

  // Obtener las últimas N notificaciones
  Stream<List<IncidentNotification>> getRecentIncidentNotifications({
    int limit = 10,
  }) {
    return _firestore
        .collection('incident_notifications')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => IncidentNotification.fromMap(doc.data()))
                  .toList(),
        );
  }

  // Eliminar notificaciones antiguas (más de 30 días)
  Future<void> cleanOldNotifications() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final oldNotifications =
          await _firestore
              .collection('incident_notifications')
              .where('timestamp', isLessThan: thirtyDaysAgo.toIso8601String())
              .get();

      final batch = _firestore.batch();
      for (var doc in oldNotifications.docs) {
        batch.delete(doc.reference);
      }

      if (oldNotifications.docs.isNotEmpty) {
        await batch.commit();
      }
    } catch (e) {
      print('Error cleaning old notifications: $e');
    }
  }

  // Método para crear notificaciones de prueba (temporal)
  Future<void> createTestNotifications() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Obtener el ID de la comunidad del usuario actual
      final userRole = await _userRoleService.getUserRoleAndCommunity(user.uid);
      final communityId = userRole?['communityId'] as String? ?? '';

      // Si no hay comunidad, no crear notificaciones de prueba
      if (communityId.isEmpty) return;

      final testNotifications = [
        {
          'incidentId': 'test_1',
          'incidentTitle': 'Problema con la calefacción',
          'type': 'created',
          'message': 'Nueva incidencia creada: Problema con la calefacción',
        },
        {
          'incidentId': 'test_1',
          'incidentTitle': 'Problema con la calefacción',
          'type': 'status_changed',
          'message': 'Estado cambiado de "open" a "in_progress"',
          'oldValue': 'open',
          'newValue': 'in_progress',
        },
        {
          'incidentId': 'test_2',
          'incidentTitle': 'Ruido en el ascensor',
          'type': 'created',
          'message': 'Nueva incidencia creada: Ruido en el ascensor',
        },
        {
          'incidentId': 'test_1',
          'incidentTitle': 'Problema con la calefacción',
          'type': 'completed',
          'message': 'Incidencia completada: Problema con la calefacción',
          'oldValue': 'in_progress',
          'newValue': 'closed',
        },
        {
          'incidentId': 'test_3',
          'incidentTitle': 'Goteo en el garaje',
          'type': 'created',
          'message': 'Nueva incidencia creada: Goteo en el garaje',
        },
      ];

      for (int i = 0; i < testNotifications.length; i++) {
        final notification = testNotifications[i];
        final testNotification = IncidentNotification(
          id: 'test_${DateTime.now().millisecondsSinceEpoch}_$i',
          incidentId: notification['incidentId'] as String,
          incidentTitle: notification['incidentTitle'] as String,
          type: notification['type'] as String,
          message: notification['message'] as String,
          oldValue: notification['oldValue'],
          newValue: notification['newValue'],
          timestamp: DateTime.now().subtract(Duration(hours: i * 2)),
          userId: user.uid,
          userEmail: user.email ?? '',
          communityId: communityId, // Añadimos el ID de la comunidad
        );

        await _firestore
            .collection('incident_notifications')
            .doc(testNotification.id)
            .set(testNotification.toMap());
      }
    } catch (e) {
      print('Error creating test notifications: $e');
    }
  }

  // Ocultar una notificación para un usuario específico
  Future<void> hideNotificationForUser(
    String notificationId,
    String userId,
  ) async {
    try {
      final docRef = _firestore
          .collection('incident_notifications')
          .doc(notificationId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        final data = snapshot.data()!;
        final hiddenByUsers = List<String>.from(data['hiddenByUsers'] ?? []);

        if (!hiddenByUsers.contains(userId)) {
          hiddenByUsers.add(userId);
          transaction.update(docRef, {'hiddenByUsers': hiddenByUsers});
        }
      });
    } catch (e) {
      print('Error hiding notification for user: $e');
      rethrow;
    }
  }

  // Ocultar múltiples notificaciones para un usuario específico
  Future<void> hideMultipleNotificationsForUser(
    List<String> notificationIds,
    String userId,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final id in notificationIds) {
        final docRef = _firestore.collection('incident_notifications').doc(id);
        batch.update(docRef, {
          'hiddenByUsers': FieldValue.arrayUnion([userId]),
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error hiding multiple notifications for user: $e');
      rethrow;
    }
  }

  // Obtener notificaciones no ocultas para un usuario específico de su comunidad
  Stream<List<IncidentNotification>> getVisibleNotificationsForUser(
    String userId,
    String communityId, {
    int limit = 20,
  }) {
    return _firestore
        .collection('incident_notifications')
        .where('communityId', isEqualTo: communityId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          // Obtener la fecha de creación del usuario actual
          final user = FirebaseAuth.instance.currentUser;
          final userCreationTime = user?.metadata.creationTime;

          return snapshot.docs
              .map((doc) => IncidentNotification.fromMap(doc.data()))
              .where((notification) {
                // Filtrar notificaciones ocultas por el usuario
                if (notification.hiddenByUsers.contains(userId)) {
                  return false;
                }

                // Filtrar notificaciones anteriores a la creación del usuario
                if (userCreationTime != null &&
                    notification.timestamp.isBefore(userCreationTime)) {
                  return false;
                }

                return true;
              })
              .toList();
        });
  }

  // Eliminar una notificación específica
  Future<void> deleteIncidentNotification(String notificationId) async {
    try {
      await _firestore
          .collection('incident_notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      print('Error deleting incident notification: $e');
      rethrow;
    }
  }

  // Eliminar múltiples notificaciones de manera eficiente
  Future<void> deleteMultipleNotifications(List<String> notificationIds) async {
    try {
      final batch = _firestore.batch();

      for (final id in notificationIds) {
        final docRef = _firestore.collection('incident_notifications').doc(id);
        batch.delete(docRef);
      }

      await batch.commit();
    } catch (e) {
      print('Error deleting multiple notifications: $e');
      rethrow;
    }
  }
}
