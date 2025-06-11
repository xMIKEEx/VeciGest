import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vecigest/domain/models/chat_notification_model.dart';
import 'package:vecigest/data/services/chat_notification_service.dart';
import 'package:vecigest/data/services/user_role_service.dart';
import 'package:vecigest/presentation/chat/widgets/chat_notification_header.dart';
import 'package:vecigest/presentation/chat/widgets/chat_notification_item.dart';
import 'package:vecigest/presentation/chat/widgets/chat_notification_states.dart';
import 'package:vecigest/utils/routes.dart';

class ChatNotificationsWidget extends StatefulWidget {
  final VoidCallback? onTap;

  const ChatNotificationsWidget({super.key, this.onTap});

  @override
  State<ChatNotificationsWidget> createState() =>
      _ChatNotificationsWidgetState();
}

class _ChatNotificationsWidgetState extends State<ChatNotificationsWidget>
    with SingleTickerProviderStateMixin {
  final ChatNotificationService _notificationService =
      ChatNotificationService();
  final UserRoleService _userRoleService = UserRoleService();
  String? _userCommunityId;

  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserCommunityId();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserCommunityId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRole = await _userRoleService.getUserRoleAndCommunity(user.uid);
      if (mounted) {
        setState(() {
          _userCommunityId = userRole?['communityId'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return ChatNotificationStates.buildErrorState(context);
    }

    // Use a default community ID if not loaded yet
    final communityId = _userCommunityId ?? '';
    if (communityId.isEmpty) {
      return ChatNotificationStates.buildLoadingState(context);
    }

    return StreamBuilder<List<ChatNotification>>(
      stream: _notificationService.getVisibleNotificationsForUser(
        user.uid,
        communityId,
        limit: 10,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ChatNotificationStates.buildErrorState(context);
        }

        final notifications = snapshot.data ?? [];
        if (notifications.isEmpty) {
          return ChatNotificationStates.buildEmptyState(context);
        }

        return _buildNotificationsList(notifications);
      },
    );
  }

  Widget _buildNotificationsList(List<ChatNotification> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return ChatNotificationHeader(
              notifications: notifications,
              isExpanded: _animationController.value > 0.5,
              onTap: _toggleExpansion,
            );
          },
        ),
        AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            return ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: _expandAnimation.value,
                child: child,
              ),
            );
          },
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Column(
                children: [
                  const SizedBox(height: 8),
                  ...notifications.asMap().entries.map(
                    (entry) => ChatNotificationItem(
                      notification: entry.value,
                      index: entry.key,
                      isExpanded: _animationController.value > 0.5,
                      onTap: () => _navigateToChat(entry.value),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Show "Ver todos" button if there are notifications
                  if (notifications.isNotEmpty)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: _navigateToAllChats,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 16,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Ver todos los chats',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _toggleExpansion() {
    if (_animationController.value == 0.0) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _navigateToChat(ChatNotification notification) {
    // Navigate to specific chat thread
    Navigator.pushNamed(
      context,
      AppRoutes.chatMessages,
      arguments: notification.threadId,
    );
  }

  void _navigateToAllChats() {
    // Navigate to chat list page (this should be handled by the parent widget)
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }
}
