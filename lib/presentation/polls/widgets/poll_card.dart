import 'package:flutter/material.dart';
import 'package:vecigest/domain/models/poll_model.dart';
import 'package:vecigest/domain/models/poll_option_model.dart';
import 'package:vecigest/presentation/polls/widgets/mini_progress.dart';
import 'package:vecigest/presentation/polls/utils/poll_colors.dart';
import 'package:vecigest/presentation/polls/utils/date_formatter.dart';

class PollCard extends StatelessWidget {
  final PollModel poll;
  final int index;
  final List<PollOptionModel> options;
  final bool hasVoted;
  final int totalVotes;
  final VoidCallback onCardTap;
  final VoidCallback onVoteButtonTap;

  const PollCard({
    super.key,
    required this.poll,
    required this.index,
    required this.options,
    required this.hasVoted,
    required this.totalVotes,
    required this.onCardTap,
    required this.onVoteButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = PollColors.colors[index % PollColors.colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 8,
        shadowColor: cardColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: onCardTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cardColor.withOpacity(0.1),
                  cardColor.withOpacity(0.05),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme, cardColor),
                  const SizedBox(height: 16),
                  _buildContent(theme, cardColor),
                  const SizedBox(height: 16),
                  _buildActionButton(cardColor),
                ],
              ),
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
          child: Icon(Icons.poll, color: cardColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                poll.question,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                DateFormatter.formatDate(poll.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasVoted ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasVoted ? Icons.check_circle : Icons.schedule,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            hasVoted ? 'Votado' : 'Pendiente',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, Color cardColor) {
    if (totalVotes > 0) {
      return Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.people,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 8),
              Text(
                '$totalVotes ${totalVotes == 1 ? 'voto' : 'votos'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const Spacer(),
              Text(
                '${options.length} opciones',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MiniProgress(options: options, totalVotes: totalVotes),
        ],
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.poll_outlined, color: cardColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '¡Sé el primero en votar! ${options.length} opciones disponibles',
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
  }

  Widget _buildActionButton(Color cardColor) {
    if (hasVoted) {
      // No button when voted - user can tap the card to see results
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onVoteButtonTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: cardColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.how_to_vote, size: 20),
        label: const Text(
          'Votar Ahora',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
