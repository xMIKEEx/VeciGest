import 'package:flutter/material.dart';
import 'package:vecigest/domain/models/poll_model.dart';
import 'package:vecigest/domain/models/poll_option_model.dart';
import 'package:vecigest/data/services/poll_service.dart';

class PollNotificationItem extends StatelessWidget {
  final PollModel poll;
  final int index;
  final bool isExpanded;
  final VoidCallback? onTap;

  const PollNotificationItem({
    super.key,
    required this.poll,
    required this.index,
    required this.isExpanded,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 200 + (index * 50)),
      opacity: isExpanded ? 1.0 : 0.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200 + (index * 50)),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            splashColor: Colors.purple.shade600.withOpacity(0.1),
            highlightColor: Colors.purple.shade600.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade600.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.poll,
                          size: 16,
                          color: Colors.purple.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          poll.question,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            fontFamily: 'Inter',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.purple.shade600,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildPollProgress(),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(poll.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                          fontFamily: 'Inter',
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.purple.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.how_to_vote,
                              size: 12,
                              color: Colors.purple[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Votar',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.purple[700],
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPollProgress() {
    return StreamBuilder<List<PollOptionModel>>(
      stream: PollService().getOptions(poll.id),
      builder: (context, snapshot) {
        final options = snapshot.data ?? [];
        final totalVotes = options.fold<int>(
          0,
          (sum, option) => sum + option.votes,
        );

        if (options.isEmpty || totalVotes == 0) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '0 votos',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.poll_outlined,
                    size: 10,
                    color: Colors.purple[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '¡Sé el primero en votar! • ${options.length} opciones',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.purple[600],
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Nueva',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Row(
                        children:
                            options
                                .asMap()
                                .entries
                                .where((entry) => entry.value.votes > 0)
                                .map((entry) {
                                  final index = entry.key;
                                  final option = entry.value;
                                  final percentage = option.votes / totalVotes;
                                  final colors = [
                                    const Color(0xFF2196F3), // Azul vibrante
                                    const Color(0xFF4CAF50), // Verde brillante
                                    const Color(0xFFFF5722), // Naranja intenso
                                    const Color(0xFF9C27B0), // Púrpura vibrante
                                    const Color(
                                      0xFFFFEB3B,
                                    ), // Amarillo brillante
                                    const Color(0xFFE91E63), // Rosa intenso
                                    const Color(0xFF00BCD4), // Cian brillante
                                    const Color(0xFFFF9800), // Naranja dorado
                                    const Color(0xFF607D8B), // Azul grisáceo
                                    const Color(0xFF795548), // Marrón
                                  ];

                                  return Flexible(
                                    flex: (percentage * 1000).round(),
                                    child: Container(
                                      height: 6,
                                      color: colors[index % colors.length],
                                    ),
                                  );
                                })
                                .toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$totalVotes votos',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Leyenda de colores y votaciones
            Wrap(
              spacing: 6,
              runSpacing: 3,
              children:
                  options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final colors = [
                      const Color(0xFF2196F3), // Azul vibrante
                      const Color(0xFF4CAF50), // Verde brillante
                      const Color(0xFFFF5722), // Naranja intenso
                      const Color(0xFF9C27B0), // Púrpura vibrante
                      const Color(0xFFFFEB3B), // Amarillo brillante
                      const Color(0xFFE91E63), // Rosa intenso
                      const Color(0xFF00BCD4), // Cian brillante
                      const Color(0xFFFF9800), // Naranja dorado
                      const Color(0xFF607D8B), // Azul grisáceo
                      const Color(0xFF795548), // Marrón
                    ];

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colors[index % colors.length],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${option.text.length > 8 ? '${option.text.substring(0, 8)}...' : option.text}: ${option.votes}',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.trending_up, size: 10, color: Colors.purple[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${options.length} opciones • Toca para votar',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.purple[600],
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                if (totalVotes > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Activa',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
