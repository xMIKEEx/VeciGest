import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vecigest/domain/models/incident_notification_model.dart';
import 'package:vecigest/data/services/incident_notification_service.dart';

class NotificationManager {
  final IncidentNotificationService _notificationService;

  NotificationManager(this._notificationService);

  // Ocultar una notificación individual para el usuario actual
  Future<void> hideNotification(
    BuildContext context,
    IncidentNotification notification,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _notificationService.hideNotificationForUser(
        notification.id,
        user.uid,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Notificación ocultada de tu historial',
              style: TextStyle(fontFamily: 'Inter'),
            ),
            backgroundColor: Colors.blue[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al ocultar notificación: $e',
              style: const TextStyle(fontFamily: 'Inter'),
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Ocultar todas las notificaciones para el usuario actual
  Future<void> hideAllNotifications(
    BuildContext context,
    List<IncidentNotification> notifications,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final notificationIds = notifications.map((n) => n.id).toList();
      await _notificationService.hideMultipleNotificationsForUser(
        notificationIds,
        user.uid,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Se ocultaron ${notifications.length} notificaciones de tu historial',
              style: const TextStyle(fontFamily: 'Inter'),
            ),
            backgroundColor: Colors.blue[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al ocultar notificaciones: $e',
              style: const TextStyle(fontFamily: 'Inter'),
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Eliminar todas las notificaciones permanentemente
  Future<void> deleteAllNotifications(
    BuildContext context,
    List<IncidentNotification> notifications,
  ) async {
    try {
      final notificationIds = notifications.map((n) => n.id).toList();
      await _notificationService.deleteMultipleNotifications(notificationIds);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Se eliminaron ${notifications.length} notificaciones',
              style: const TextStyle(fontFamily: 'Inter'),
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al eliminar notificaciones: $e',
              style: const TextStyle(fontFamily: 'Inter'),
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
