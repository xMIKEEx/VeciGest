import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final User? user;
  final double radius;

  const UserAvatar({super.key, required this.user, this.radius = 30});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      backgroundImage:
          user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
      child: user?.photoURL == null
          ? (user != null
              ? Text(
                  _initialFromUser(user!),
                  style: TextStyle(
                    fontSize: radius * 0.8,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : Icon(
                  Icons.person,
                  size: radius,
                  color: Theme.of(context).colorScheme.primary,
                ))
          : null,
    );
  }
}

String _initialFromUser(User user) {
  final name = user.displayName;
  if (name != null && name.isNotEmpty) {
    return name[0].toUpperCase();
  }
  final email = user.email;
  if (email != null && email.isNotEmpty) {
    return email[0].toUpperCase();
  }
  return '?';
}
