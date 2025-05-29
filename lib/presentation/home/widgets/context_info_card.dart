import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'user_avatar.dart';

class ContextInfoCard extends StatelessWidget {
  final Map<String, dynamic>? userRole;
  final bool isAdmin;

  const ContextInfoCard({
    super.key,
    required this.userRole,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            UserAvatar(user: user),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userRole?['viviendaId'] ?? '1·A',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userRole?['communityName'] ?? 'Mi Comunidad',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            if (isAdmin)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Admin',
                  style: TextStyle(
                    color: Colors.amber[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
