import 'package:flutter/material.dart';
import 'package:vecigest/domain/models/poll_model.dart';
import 'package:vecigest/data/services/poll_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vecigest/presentation/polls/widgets/poll_notification_header.dart';
import 'package:vecigest/presentation/polls/widgets/poll_notification_item.dart';
import 'package:vecigest/presentation/polls/widgets/poll_notification_states.dart';
import 'package:vecigest/presentation/polls/managers/poll_notification_manager.dart';
import 'package:vecigest/utils/routes.dart';

class PollNotificationsWidget extends StatefulWidget {
  final VoidCallback? onTap;

  const PollNotificationsWidget({super.key, this.onTap});

  @override
  State<PollNotificationsWidget> createState() =>
      _PollNotificationsWidgetState();
}

class _PollNotificationsWidgetState extends State<PollNotificationsWidget>
    with SingleTickerProviderStateMixin {
  final PollService _pollService = PollService();
  late final PollNotificationManager _notificationManager;

  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _notificationManager = PollNotificationManager(_pollService);
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return PollNotificationStates.buildErrorState(context);
    }

    return StreamBuilder<List<PollModel>>(
      stream: _pollService.getPolls(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return PollNotificationStates.buildErrorState(context);
        }

        final allPolls = snapshot.data ?? [];
        if (allPolls.isEmpty) {
          return PollNotificationStates.buildEmptyState(context);
        }

        return FutureBuilder<List<PollModel>>(
          future: _notificationManager.getUnvotedPolls(allPolls, user.uid),
          builder: (context, unvotedSnapshot) {
            if (unvotedSnapshot.connectionState == ConnectionState.waiting) {
              return PollNotificationStates.buildLoadingState(context);
            }

            final unvotedPolls = unvotedSnapshot.data ?? [];
            if (unvotedPolls.isEmpty) {
              return PollNotificationStates.buildEmptyState(context);
            }

            return _buildPollNotificationsList(unvotedPolls);
          },
        );
      },
    );
  }

  Widget _buildPollNotificationsList(List<PollModel> unvotedPolls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return PollNotificationHeader(
              unvotedPolls: unvotedPolls,
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
                  ...unvotedPolls.asMap().entries.map(
                    (entry) => PollNotificationItem(
                      poll: entry.value,
                      index: entry.key,
                      isExpanded: _animationController.value > 0.5,
                      onTap: () => _navigateToPollDetail(entry.value),
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

  void _navigateToPollDetail(PollModel poll) {
    Navigator.pushNamed(context, AppRoutes.pollDetail, arguments: poll);
  }
}
