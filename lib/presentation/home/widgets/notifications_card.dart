import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vecigest/data/services/chat_service.dart';
import 'package:vecigest/data/services/poll_service.dart';
import 'package:vecigest/domain/models/thread_model.dart';
import 'package:vecigest/domain/models/poll_model.dart';
import 'package:vecigest/presentation/incidents/incident_notifications_widget.dart';
import 'notification_tile.dart';

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

        // Incident notifications
        const IncidentNotificationsWidget(),
        const SizedBox(height: 8),

        // Chat notifications
        _buildChatNotifications(),
        const SizedBox(height: 8),

        // Poll notifications
        _buildPollNotifications(),
        const SizedBox(height: 8),

        // Additional notifications
        NotificationTile(
          icon: Icons.description,
          title: 'Nuevos documentos',
          subtitle: 'Revisa los documentos recientes',
          color: Colors.green,
          onTap: onOpenSettings,
        ),
      ],
    );
  }

  Widget _buildChatNotifications() {
    return StreamBuilder<List<ThreadModel>>(
      stream: ChatService().getThreads(),
      builder: (context, snapshot) {
        final threads = snapshot.data ?? [];
        final unreadCount = threads.length;

        return NotificationTile(
          icon: Icons.chat_bubble,
          title: 'Mensajes sin leer',
          subtitle:
              unreadCount > 0
                  ? '$unreadCount hilos activos'
                  : 'No hay mensajes nuevos',
          color: unreadCount > 0 ? Colors.blue : Colors.grey,
          onTap: () => onNavigateToTab(3),
        );
      },
    );
  }

  Widget _buildPollNotifications() {
    final pollService = PollService();

    return StreamBuilder<List<PollModel>>(
      stream: pollService.getPolls(),
      builder: (context, snapshot) {
        final polls = snapshot.data ?? [];
        final user = FirebaseAuth.instance.currentUser;

        if (user == null || polls.isEmpty) {
          return NotificationTile(
            icon: Icons.poll,
            title: 'Encuestas sin votar',
            subtitle: 'No hay encuestas pendientes',
            color: Colors.grey,
            onTap: () => onNavigateToTab(4),
          );
        }

        return FutureBuilder<List<bool>>(
          future: Future.wait(
            polls.map((poll) => pollService.hasUserVoted(poll.id, user.uid)),
          ),
          builder: (context, votedSnapshot) {
            if (!votedSnapshot.hasData) {
              return NotificationTile(
                icon: Icons.poll,
                title: 'Encuestas sin votar',
                subtitle: 'Cargando...',
                color: Colors.grey,
                onTap: () => onNavigateToTab(4),
              );
            }

            final votedList = votedSnapshot.data!;
            final unvotedCount = votedList.where((voted) => !voted).length;

            return NotificationTile(
              icon: Icons.poll,
              title: 'Encuestas sin votar',
              subtitle:
                  unvotedCount > 0
                      ? '$unvotedCount encuestas disponibles'
                      : 'No hay encuestas pendientes',
              color: unvotedCount > 0 ? Colors.purple : Colors.grey,
              onTap: () => onNavigateToTab(4),
            );
          },
        );
      },
    );
  }
}
