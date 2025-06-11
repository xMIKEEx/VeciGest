import 'package:flutter/material.dart';

class FloatingTopBar extends StatelessWidget {
  final bool hasSubPages;
  final VoidCallback? onBackPressed;
  final VoidCallback onSettingsPressed;

  const FloatingTopBar({
    super.key,
    required this.hasSubPages,
    this.onBackPressed,
    required this.onSettingsPressed,
  });
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              if (hasSubPages)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBackPressed,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              if (!hasSubPages) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'VeciGest',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: onSettingsPressed,
                tooltip: 'Ajustes',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
