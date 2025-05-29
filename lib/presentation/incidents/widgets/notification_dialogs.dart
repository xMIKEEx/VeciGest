import 'package:flutter/material.dart';
import 'package:vecigest/domain/models/incident_notification_model.dart';

class NotificationDialogs {
  static void showNotificationDetails(
    BuildContext context,
    IncidentNotification notification,
    VoidCallback onHide,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTypeColor(notification.type).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTypeIcon(notification.type),
                  color: _getTypeColor(notification.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Detalle de cambio',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Incidencia', notification.incidentTitle),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Tipo de cambio',
                _getTypeDisplayText(notification.type),
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Fecha',
                _formatTimestamp(notification.timestamp),
              ),
              if (notification.oldValue != null &&
                  notification.newValue != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Cambio realizado',
                  '${notification.oldValue} → ${notification.newValue}',
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cerrar',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onHide();
              },
              child: Text(
                'Ocultar',
                style: TextStyle(
                  color: Colors.orange[600],
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static void showDeleteAllDialog(
    BuildContext context,
    List<IncidentNotification> notifications,
    VoidCallback onHideAll,
    VoidCallback onDeletePermanently,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.clear_all, color: Colors.blue[600], size: 24),
              const SizedBox(width: 12),
              const Text(
                'Gestionar historial',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tienes ${notifications.length} notificaciones en tu historial.',
                style: const TextStyle(fontSize: 14, fontFamily: 'Inter'),
              ),
              const SizedBox(height: 16),
              const Text(
                '¿Qué deseas hacer?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontFamily: 'Inter',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onHideAll();
              },
              child: Text(
                'Ocultar de mi historial',
                style: TextStyle(color: Colors.blue[600], fontFamily: 'Inter'),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                showDeletePermanentlyDialog(
                  context,
                  notifications,
                  onDeletePermanently,
                );
              },
              child: const Text(
                'Eliminar permanentemente',
                style: TextStyle(fontFamily: 'Inter'),
              ),
            ),
          ],
        );
      },
    );
  }

  static void showDeletePermanentlyDialog(
    BuildContext context,
    List<IncidentNotification> notifications,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.red[600], size: 24),
              const SizedBox(width: 12),
              const Text(
                'Eliminar permanentemente',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '⚠️ ATENCIÓN: Esta acción no se puede deshacer',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Esto eliminará PERMANENTEMENTE todas las ${notifications.length} notificaciones de la base de datos para TODOS los usuarios.',
                style: const TextStyle(fontSize: 14, fontFamily: 'Inter'),
              ),
              const SizedBox(height: 8),
              const Text(
                'Si solo quieres que desaparezcan de tu historial, usa "Ocultar de mi historial" en su lugar.',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontFamily: 'Inter',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text(
                'Sí, eliminar permanentemente',
                style: TextStyle(
                  color: Colors.red[600],
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontFamily: 'Inter')),
      ],
    );
  }

  static String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  static String _getTypeDisplayText(String type) {
    switch (type) {
      case 'created':
        return 'Creada';
      case 'status_changed':
        return 'Estado cambiado';
      case 'completed':
        return 'Completada';
      case 'updated':
        return 'Actualizada';
      case 'deleted':
        return 'Eliminada';
      default:
        return 'Cambio';
    }
  }

  static IconData _getTypeIcon(String type) {
    switch (type) {
      case 'created':
        return Icons.add_circle;
      case 'status_changed':
        return Icons.sync_alt;
      case 'completed':
        return Icons.check_circle;
      case 'updated':
        return Icons.edit;
      case 'deleted':
        return Icons.delete;
      default:
        return Icons.info;
    }
  }

  static Color _getTypeColor(String type) {
    switch (type) {
      case 'created':
        return Colors.green;
      case 'status_changed':
        return Colors.blue;
      case 'completed':
        return Colors.purple;
      case 'updated':
        return Colors.orange;
      case 'deleted':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
