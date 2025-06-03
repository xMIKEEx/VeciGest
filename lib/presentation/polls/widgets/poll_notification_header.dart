import 'package:flutter/material.dart';
import 'package:vecigest/domain/models/poll_model.dart';

class PollNotificationHeader extends StatelessWidget {
  final List<PollModel> unvotedPolls;
  final bool isExpanded;
  final VoidCallback? onTap;

  const PollNotificationHeader({
    super.key,
    required this.unvotedPolls,
    required this.isExpanded,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final recentCount =
        unvotedPolls
            .where(
              (poll) => DateTime.now().difference(poll.createdAt).inHours < 24,
            )
            .length;
    final headerColor = _getHeaderColor(unvotedPolls);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: unvotedPolls.isNotEmpty ? onTap : null,
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
                child: Icon(Icons.poll, color: headerColor, size: 20),
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
                            'Encuestas',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        if (unvotedPolls.isNotEmpty) ...[
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
                      recentCount > 0
                          ? '$recentCount encuestas nuevas'
                          : '${unvotedPolls.length} encuestas sin votar',
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

  Color _getHeaderColor(List<PollModel> polls) {
    if (polls.isEmpty) return Colors.grey;

    final now = DateTime.now();
    final hasRecent = polls.any(
      (poll) => now.difference(poll.createdAt).inHours < 1,
    );

    if (hasRecent) return Colors.purple;

    final hasToday = polls.any(
      (poll) => now.difference(poll.createdAt).inDays < 1,
    );

    if (hasToday) return Colors.deepPurple;

    return Colors.indigo;
  }
}
