import 'package:flutter/material.dart';
import 'package:vecigest/domain/models/incident_notification_model.dart';

class NotificationItem extends StatelessWidget {
  final IncidentNotification notification;
  final VoidCallback onTap;
  final int index;
  final bool isExpanded;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
    required this.index,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(notification.type);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 250 + (index * 60)),
      tween: Tween(begin: isExpanded ? 0.0 : 1.0, end: isExpanded ? 1.0 : 0.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        child: Material(
          color: typeColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: typeColor.withOpacity(0.2), width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: typeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                notification.incidentTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _formatTimestamp(notification.timestamp),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.5),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.4),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                _getTypeDisplayText(notification.type),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: typeColor,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                            if (notification.oldValue != null &&
                                notification.newValue != null) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${notification.oldValue} → ${notification.newValue}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'Inter',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
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

  String _getTypeDisplayText(String type) {
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

  Color _getTypeColor(String type) {
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
