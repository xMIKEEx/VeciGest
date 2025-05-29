import 'package:flutter/material.dart';
import 'package:vecigest/domain/models/incident_notification_model.dart';
import 'package:vecigest/data/services/incident_notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vecigest/data/services/user_role_service.dart';
import 'package:vecigest/presentation/incidents/widgets/notification_header.dart';
import 'package:vecigest/presentation/incidents/widgets/notification_item.dart';
import 'package:vecigest/presentation/incidents/widgets/notification_dialogs.dart';
import 'package:vecigest/presentation/incidents/widgets/notification_states.dart';
import 'package:vecigest/presentation/incidents/managers/notification_manager.dart';

class IncidentNotificationsWidget extends StatefulWidget {
  final VoidCallback? onTap;

  const IncidentNotificationsWidget({super.key, this.onTap});

  @override
  State<IncidentNotificationsWidget> createState() =>
      _IncidentNotificationsWidgetState();
}

class _IncidentNotificationsWidgetState
    extends State<IncidentNotificationsWidget>
    with SingleTickerProviderStateMixin {
  final IncidentNotificationService _notificationService =
      IncidentNotificationService();
  final UserRoleService _userRoleService = UserRoleService();
  late final NotificationManager _notificationManager;
  String? _userCommunityId;
  bool _isExpanded = false;

  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _notificationManager = NotificationManager(_notificationService);
    _loadUserCommunityId();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
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
      setState(() {
        _userCommunityId = userRole?['communityId'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userCommunityId == null) {
      return NotificationStates.buildLoadingState(context);
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return NotificationStates.buildErrorState(context);
    }

    return StreamBuilder<List<IncidentNotification>>(
      stream: _notificationService.getVisibleNotificationsForUser(
        user.uid,
        _userCommunityId!,
        limit: 20,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return NotificationStates.buildLoadingState(context);
        }
        if (snapshot.hasError) {
          return NotificationStates.buildErrorState(context);
        }
        final notifications = snapshot.data ?? [];
        if (notifications.isEmpty) {
          return NotificationStates.buildEmptyState(context);
        }
        return _buildNotificationsList(notifications);
      },
    );
  }

  Widget _buildNotificationsList(List<IncidentNotification> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotificationHeader(
          notifications: notifications,
          isExpanded: _isExpanded,
          onTap: _toggleExpansion,
          onDeleteAll: () => _showDeleteAllDialog(notifications),
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
          child: Column(
            children: [
              const SizedBox(height: 8),
              ...notifications.asMap().entries.map(
                (entry) => NotificationItem(
                  notification: entry.value,
                  index: entry.key,
                  isExpanded: _isExpanded,
                  onTap: () => _showNotificationDetails(entry.value),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _showNotificationDetails(IncidentNotification notification) {
    NotificationDialogs.showNotificationDetails(
      context,
      notification,
      () => _notificationManager.hideNotification(context, notification),
    );
  }

  void _showDeleteAllDialog(List<IncidentNotification> notifications) {
    NotificationDialogs.showDeleteAllDialog(
      context,
      notifications,
      () => _notificationManager.hideAllNotifications(context, notifications),
      () => _notificationManager.deleteAllNotifications(context, notifications),
    );
  }
}
