import 'package:flutter/material.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Incidencias'),
        BottomNavigationBarItem(
          icon: Icon(Icons.insert_drive_file),
          label: 'Documentos',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.poll), label: 'Encuestas'),
      ],
      type: BottomNavigationBarType.fixed,
    );
  }
}
