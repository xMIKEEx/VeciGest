import 'package:flutter/material.dart';

class NavigationBadge extends StatelessWidget {
  final IconData iconData;
  final Stream<List<dynamic>> stream;
  final int Function(List<dynamic> data) countExtractor;
  final Color badgeColor;

  const NavigationBadge({
    super.key,
    required this.iconData,
    required this.stream,
    required this.countExtractor,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(iconData),
        StreamBuilder<List<dynamic>>(
          stream: stream,
          builder: (context, snapshot) {
            final data = snapshot.data ?? [];
            final count = countExtractor(data);

            if (count == 0) return const SizedBox.shrink();

            return Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                child: Text(
                  count > 9 ? '9+' : count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
