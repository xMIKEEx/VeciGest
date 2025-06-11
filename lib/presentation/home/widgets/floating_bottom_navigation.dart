import 'package:flutter/material.dart';
import 'package:vecigest/data/services/incident_service.dart';
import 'package:vecigest/data/services/chat_service.dart';

class FloatingBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final IncidentService incidentService;
  final ChatService chatService;

  const FloatingBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.incidentService,
    required this.chatService,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                context,
                0,
                Icons.report_problem_outlined,
                Icons.report_problem,
                'Incidencias',
              ),
              _buildNavItem(
                context,
                1,
                Icons.event_available_outlined,
                Icons.event_available,
                'Reservas',
              ),
              _buildNavItem(
                context,
                2,
                Icons.home_outlined,
                Icons.home,
                'Home',
                isHome: true,
              ),
              _buildNavItem(
                context,
                3,
                Icons.chat_bubble_outline,
                Icons.chat_bubble,
                'Chat',
              ),
              _buildNavItem(
                context,
                4,
                Icons.poll_outlined,
                Icons.poll,
                'Encuestas',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData outlinedIcon,
    IconData filledIcon,
    String label, {
    bool isHome = false,
  }) {
    final isSelected = currentIndex == index;

    // Define colors for each function
    Color getIconColor() {
      if (isSelected) {
        return Theme.of(context).colorScheme.primary;
      }

      switch (index) {
        case 0: // Incidencias
          return Colors.red.shade600;
        case 1: // Reservas
          return Colors.green.shade600;
        case 2: // Home
          return Colors.blue.shade600;
        case 3: // Chat
          return Colors.orange.shade600;
        case 4: // Encuestas
          return Colors.purple.shade600;
        default:
          return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
      }
    }

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlinedIcon,
              color: getIconColor(),
              size: isHome ? 28 : 24,
            ),
          ],
        ),
      ),
    );
  }
}
