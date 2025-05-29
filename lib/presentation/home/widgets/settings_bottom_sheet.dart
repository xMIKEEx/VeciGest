import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vecigest/utils/routes.dart';
import '../../../main.dart';
import 'user_avatar.dart';

class SettingsBottomSheet extends StatelessWidget {
  final bool isAdmin;

  const SettingsBottomSheet({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // User info
            ListTile(
              leading: UserAvatar(user: user),
              title: Text(
                user?.email ?? 'Usuario',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(isAdmin ? 'Administrador' : 'Residente'),
            ),

            const Divider(),

            // Documents
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Documentos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.documents);
              },
            ),

            // Communities & Properties (Admin only)
            if (isAdmin)
              ListTile(
                leading: const Icon(Icons.apartment),
                title: const Text('Comunidades & Viviendas'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to communities management
                },
              ),

            // Dark mode toggle
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: const Text('Tema oscuro'),
              value:
                  Provider.of<ThemeProvider>(context).themeMode ==
                  ThemeMode.dark,
              onChanged: (value) {
                Provider.of<ThemeProvider>(
                  context,
                  listen: false,
                ).setTheme(value ? ThemeMode.dark : ThemeMode.light);
              },
            ),

            const Divider(),

            // About
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Acerca de'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'VeciGest',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2025 VeciGest',
                );
              },
            ),

            // Sign out
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
