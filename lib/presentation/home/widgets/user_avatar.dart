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
      child:
          user?.email != null
              ? Text(
                user!.email![0].toUpperCase(),
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
              ),
    );
  }
}
