import 'package:flutter/material.dart';

class PollStates {
  static Widget buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder:
          (context, index) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
    );
  }

  static Widget buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error al cargar encuestas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Desliza hacia abajo para reintentar',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  static Widget buildEmptyState(
    BuildContext context,
    String filter,
    bool isAdmin,
    VoidCallback? onCreatePoll,
  ) {
    String title, subtitle;
    IconData icon;

    switch (filter) {
      case 'voted':
        title = 'No has votado en ninguna encuesta';
        subtitle = 'Participa en las decisiones de tu comunidad';
        icon = Icons.how_to_vote;
        break;
      case 'unvoted':
        title = 'No hay encuestas pendientes';
        subtitle = 'Todas las encuestas han sido completadas';
        icon = Icons.check_circle_outline;
        break;
      default:
        title = 'No hay encuestas disponibles';
        subtitle =
            isAdmin
                ? 'Crea la primera encuesta para tu comunidad'
                : 'Las encuestas aparecerán aquí cuando estén disponibles';
        icon = Icons.poll_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (filter == 'all' && isAdmin && onCreatePoll != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onCreatePoll,
                icon: const Icon(Icons.add),
                label: const Text('Crear Encuesta'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
