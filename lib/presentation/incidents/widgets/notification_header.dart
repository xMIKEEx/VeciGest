import 'package:flutter/material.dart';
import 'package:vecigest/domain/models/incident_notification_model.dart';

class NotificationHeader extends StatelessWidget {
  final List<IncidentNotification> notifications;
  final bool isExpanded;
  final VoidCallback? onTap;
  final VoidCallback? onDeleteAll;

  const NotificationHeader({
    super.key,
    required this.notifications,
    required this.isExpanded,
    this.onTap,
    this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    final recentCount =
        notifications
            .where((n) => DateTime.now().difference(n.timestamp).inHours < 24)
            .length;
    final headerColor = _getHeaderColor(notifications);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: notifications.isNotEmpty ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: headerColor.withOpacity(isExpanded ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: headerColor.withOpacity(isExpanded ? 0.4 : 0.3),
            ),
            boxShadow:
                isExpanded
                    ? [
                      BoxShadow(
                        color: headerColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: headerColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.history, color: headerColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Historial de incidencias',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        if (notifications.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          AnimatedRotation(
                            duration: const Duration(milliseconds: 300),
                            turns: isExpanded ? 0.5 : 0.0,
                            child: Icon(
                              Icons.expand_more,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isExpanded)
                            Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: onDeleteAll,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(
                                    Icons.delete_sweep,
                                    size: 16,
                                    color: Colors.red[600],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      recentCount > 0
                          ? '$recentCount cambios recientes'
                          : '${notifications.length} actividades registradas',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 12,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getHeaderColor(List<IncidentNotification> notifications) {
    if (notifications.isEmpty) return Colors.grey;

    final now = DateTime.now();
    final hasRecent = notifications.any(
      (n) => now.difference(n.timestamp).inHours < 1,
    );

    if (hasRecent) return Colors.orange;

    final hasToday = notifications.any(
      (n) => now.difference(n.timestamp).inDays < 1,
    );

    if (hasToday) return Colors.blue;

    return Colors.green;
  }
}
