import 'package:flutter/material.dart';
import 'package:vecigest/domain/models/thread_model.dart';
import 'package:vecigest/presentation/chat/utils/chat_colors.dart';
import 'package:vecigest/presentation/chat/utils/date_formatter.dart';

class ChatCard extends StatelessWidget {
  final ThreadModel thread;
  final int index;
  final int messageCount;
  final VoidCallback onCardTap;
  final bool hasUnreadMessages;
  final bool isAdmin;
  final VoidCallback? onDelete;

  const ChatCard({
    super.key,
    required this.thread,
    required this.index,
    required this.messageCount,
    required this.onCardTap,
    this.hasUnreadMessages = false,
    this.isAdmin = false,
    this.onDelete,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const orangeColor = Color(0xFFFF6B35);
    final cardColor = ChatColors.colors[index % ChatColors.colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 3,
        shadowColor: orangeColor.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: InkWell(
          onTap: onCardTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme, cardColor),
                const SizedBox(height: 16),
                _buildContent(theme),
                if (thread.authorizedPropertyIds.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildPropertyInfo(theme, orangeColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, Color cardColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.chat_bubble, color: cardColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                thread.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                DateFormatter.formatDate(thread.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        if (hasUnreadMessages) _buildUnreadBadge(),
        if (isAdmin && onDelete != null) _buildDeleteButton(theme),
      ],
    );
  }

  Widget _buildUnreadBadge() {
    const orangeColor = Color(0xFFFF6B35);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: orangeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fiber_new, size: 14, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'Nuevo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (thread.description != null && thread.description!.isNotEmpty) ...[
          Text(
            thread.description!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Icon(
              Icons.message,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Text(
              '$messageCount ${messageCount == 1 ? 'mensaje' : 'mensajes'}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.people,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              thread.authorizedPropertyIds.isEmpty
                  ? 'Chat público'
                  : '${thread.authorizedPropertyIds.length} vivienda${thread.authorizedPropertyIds.length != 1 ? 's' : ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPropertyInfo(ThemeData theme, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cardColor.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.home, color: cardColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Chat privado para viviendas seleccionadas',
              style: TextStyle(
                color: cardColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onDelete,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.delete_outline,
              color: Colors.red.shade700,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
