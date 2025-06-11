import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final User? user;
  final double radius;
  final Map<String, dynamic>? userRole;

  const UserAvatar({
    super.key,
    required this.user,
    this.radius = 30,
    this.userRole,
  });

  String _getHousingDisplayForAvatar() {
    final viviendaId = userRole?['viviendaId'] as String?;
    if (viviendaId != null && viviendaId.isNotEmpty) {
      // Extract only the important part for the avatar
      // E.g., "Piso 3A" -> "3A", "Portal 2" -> "2", "1·A" -> "1A"
      final cleanedVivienda =
          viviendaId
              .replaceAll('Piso ', '')
              .replaceAll('Portal ', '')
              .replaceAll('·', '')
              .trim();

      if (cleanedVivienda.isNotEmpty) {
        return cleanedVivienda;
      }
    }
    return user?.email?[0].toUpperCase() ?? 'U';
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Text(
        _getHousingDisplayForAvatar(),
        style: TextStyle(
          fontSize: radius * 0.6, // Slightly smaller to fit housing names
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
