import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ChatStates {
  static Widget buildLoadingState() {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return ListView.builder(
          itemCount: 6,
          padding: const EdgeInsets.all(16),
          itemBuilder:
              (_, __) => Shimmer.fromColors(
                baseColor: colorScheme.surfaceContainerHighest,
                highlightColor: colorScheme.surface,
                child: Container(
                  height: 120,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
        );
      },
    );
  }

  static Widget buildErrorState(BuildContext context, VoidCallback? onRetry) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar los chats',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          if (onRetry != null)
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
        ],
      ),
    );
  }

  static Widget buildEmptyState(
    BuildContext context,
    bool isAdmin,
    VoidCallback? onCreateChat,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay chats disponibles',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isAdmin
                ? 'Crea el primer chat grupal usando el botón inferior'
                : 'Los chats aparecerán aquí cuando sean creados',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.4),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (isAdmin && onCreateChat != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onCreateChat,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Crear Chat Grupal'),
            ),
          ],
        ],
      ),
    );
  }
}
