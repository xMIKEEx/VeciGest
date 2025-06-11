import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ChatStates {
  static const Color orangeColor = Color(0xFFFF6B35);

  static Widget buildLoadingState() {
    return Builder(
      builder: (context) {
        return ListView.builder(
          itemCount: 6,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder:
              (_, __) => Shimmer.fromColors(
                baseColor: orangeColor.withOpacity(0.1),
                highlightColor: orangeColor.withOpacity(0.3),
                child: Container(
                  height: 120,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: orangeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: orangeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
                ? 'Crea el primer chat grupal usando el botón superior'
                : 'Los chats aparecerán aquí cuando sean creados',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.4),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          // Eliminado el botón duplicado del estado empty
        ],
      ),
    );
  }
}
