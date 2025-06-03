import 'package:flutter/material.dart';
import 'package:vecigest/domain/models/poll_model.dart';

class PollNotificationDialogs {
  static void showPollDetails(
    BuildContext context,
    PollModel poll,
    VoidCallback onNavigateToPoll,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.poll, color: Colors.purple[700]),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Detalles de la encuesta',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  poll.question,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Creada: ${_formatDate(poll.createdAt)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.how_to_vote, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${poll.options.length} opciones disponibles',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.purple[700],
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Aún no has votado en esta encuesta',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onNavigateToPoll();
                },
                icon: const Icon(Icons.poll),
                label: const Text('Ver encuesta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
    );
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return 'Fecha desconocida';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return 'hace ${difference.inHours} horas';
    } else if (difference.inDays == 1) {
      return 'ayer';
    } else if (difference.inDays < 7) {
      return 'hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
