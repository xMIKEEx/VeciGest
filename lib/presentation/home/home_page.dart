import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Importa las páginas placeholder (ajusta los imports según tu estructura real)
import 'package:vecigest/presentation/chat/thread_list_page.dart'; // Changed import
import 'package:vecigest/presentation/incidents/incident_list_page.dart'; // Corrected path
import 'package:vecigest/presentation/documents/doc_list_page.dart'; // Corrected path
import 'package:vecigest/presentation/polls/poll_list_page.dart'; // Corrected path
import '../../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = -1;

  final List<Widget> _pages = const [
    ThreadListPage(), // Changed to ThreadListPage
    IncidentListPage(),
    DocListPage(),
    PollListPage(),
  ];

  void _openSettings() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final user = FirebaseAuth.instance.currentUser;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(user?.email ?? 'Ver perfil'),
                subtitle: user != null ? Text('ID: ${user.uid}') : null,
                onTap: () {}, // Aquí puedes navegar a una pantalla de perfil
              ),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode),
                title: const Text('Modo oscuro'),
                value:
                    Provider.of<ThemeProvider>(context).themeMode ==
                    ThemeMode.dark,
                onChanged: (val) {
                  Provider.of<ThemeProvider>(
                    context,
                    listen: false,
                  ).setTheme(val ? ThemeMode.dark : ThemeMode.light);
                  // No cerrar el modal
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar sesión'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Acerca de'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'VeciGest',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2025 VeciGest',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    final options = [
      {'label': 'Chat', 'icon': Icons.chat, 'color': Colors.blue, 'route': 0},
      {
        'label': 'Incidencias',
        'icon': Icons.report_problem,
        'color': Colors.orange,
        'route': 1,
      },
      {
        'label': 'Documentos',
        'icon': Icons.description,
        'color': Colors.green,
        'route': 2,
      },
      {
        'label': 'Encuestas',
        'icon': Icons.poll,
        'color': Colors.purple,
        'route': 3,
      },
    ];
    if (_currentIndex < 0 || _currentIndex >= _pages.length) {
      // Dashboard
      return Scaffold(
        appBar: AppBar(
          title: const Text('VeciGest'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _openSettings,
              tooltip: 'Ajustes',
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.email != null
                                ? '¡Hola, ${user!.email}!'
                                : '¡Bienvenido!',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '¿Qué quieres hacer hoy?',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  children:
                      options.map((opt) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentIndex = opt['route'] as int;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: (opt['color'] as Color).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: (opt['color'] as Color).withOpacity(
                                    0.08,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color:
                                    _currentIndex == opt['route']
                                        ? (opt['color'] as Color)
                                        : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  opt['icon'] as IconData,
                                  size: 48,
                                  color: opt['color'] as Color,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  opt['label'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: colorScheme.onBackground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Página seleccionada
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _currentIndex = -1),
          ),
          title: const Text('VeciGest'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _openSettings,
              tooltip: 'Ajustes',
            ),
          ],
        ),
        body: _pages[_currentIndex],
      );
    }
  }
}
