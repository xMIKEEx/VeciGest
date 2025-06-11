import 'package:flutter/material.dart';
import 'package:vecigest/presentation/incidents/incident_notifications_widget.dart';
import 'package:vecigest/presentation/polls/poll_notifications_widget.dart';
import 'package:vecigest/presentation/chat/chat_notifications_widget.dart';

class NotificationsCard extends StatelessWidget {
  final Function(int) onNavigateToTab;
  final VoidCallback onOpenSettings;

  const NotificationsCard({
    super.key,
    required this.onNavigateToTab,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.notifications_active,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Notificaciones',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 1. Incidencias (Incident notifications)
        const IncidentNotificationsWidget(),
        const SizedBox(height: 8),

        // 2. Encuestas (Poll notifications)
        const PollNotificationsWidget(),
        const SizedBox(height: 8), // 3. Chats (Chat notifications)
        ChatNotificationsWidget(onTap: () => onNavigateToTab(3)),
      ],
    );
  }
}
