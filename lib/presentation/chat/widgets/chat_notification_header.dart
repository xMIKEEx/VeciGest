import 'package:flutter/material.dart';
import 'package:vecigest/domain/models/chat_notification_model.dart';

class ChatNotificationHeader extends StatelessWidget {
  final List<ChatNotification> notifications;
  final bool isExpanded;
  final VoidCallback? onTap;

  const ChatNotificationHeader({
    super.key,
    required this.notifications,
    required this.isExpanded,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unreadGroups = notifications.length;
    final totalUnreadMessages = notifications.fold<int>(
      0,
      (sum, notification) => sum + notification.unreadCount,
    );
    final headerColor = _getHeaderColor(notifications);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: notifications.isNotEmpty ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: headerColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: headerColor.withOpacity(0.35)),
            boxShadow: [
              BoxShadow(
                color: headerColor.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: headerColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.chat_bubble, color: headerColor, size: 20),
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
                            'Mensajes',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        if (notifications.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: headerColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              totalUnreadMessages.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      totalUnreadMessages > 0
                          ? '$totalUnreadMessages mensajes nuevos en $unreadGroups grupos'
                          : 'No hay mensajes nuevos',
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

  Color _getHeaderColor(List<ChatNotification> notifications) {
    if (notifications.isEmpty) return Colors.grey;

    final now = DateTime.now();

    // Check for very recent messages (within 1 hour)
    final hasVeryRecent = notifications.any(
      (n) => now.difference(n.lastMessageTime).inMinutes < 60,
    );
    if (hasVeryRecent) return Colors.orange;

    // Check for recent messages (within 24 hours)
    final hasRecent = notifications.any(
      (n) => now.difference(n.lastMessageTime).inHours < 24,
    );
    if (hasRecent) return Colors.blue;

    // Default color for older messages
    return Colors.green;
  }
}
