import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
// Importa las páginas placeholder (ajusta los imports según tu estructura real)
import 'package:vecigest/presentation/chat/thread_list_page.dart'; // Changed import
import 'package:vecigest/presentation/incidents/incident_list_page.dart'; // Corrected path
import 'package:vecigest/presentation/documents/doc_list_page.dart'; // Corrected path
import 'package:vecigest/presentation/polls/poll_list_page.dart'; // Corrected path
import 'package:vecigest/presentation/reservations/reservation_list_page.dart'; // Nueva importación
import '../../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = -1;
  String? _role;
  bool _loadingRole = true;

  final List<Widget> _pagesAdmin = const [
    ThreadListPage(),
    IncidentListPage(),
    PollListPage(),
    ReservationListPage(),
  ];
  final List<Widget> _pagesUser = const [
    ThreadListPage(),
    IncidentListPage(),
    PollListPage(),
    ReservationListPage(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchRole();
  }

  Future<void> _fetchRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _role = null;
        _loadingRole = false;
      });
      return;
    }
    try {
      final data =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      setState(() {
        _role = data.data()?['role'] as String?;
        _loadingRole = false;
      });
    } catch (e) {
      setState(() {
        _role = null;
        _loadingRole = false;
      });
    }
  }

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
                leading: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                title: Text(
                  user?.email ?? 'Ver perfil',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                subtitle:
                    user != null
                        ? Text(
                          'ID: \\${user.uid}',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        )
                        : null,
                onTap: () {}, // Aquí puedes navegar a una pantalla de perfil
              ),
              ListTile(
                leading: Icon(
                  Icons.description,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                title: Text(
                  'Documentos',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DocListPage()),
                  );
                },
              ),
              SwitchListTile(
                secondary: Icon(
                  Icons.dark_mode,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                title: Text(
                  'Modo oscuro',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                value:
                    Provider.of<ThemeProvider>(context).themeMode ==
                    ThemeMode.dark,
                onChanged: (val) {
                  Provider.of<ThemeProvider>(
                    context,
                    listen: false,
                  ).setTheme(val ? ThemeMode.dark : ThemeMode.light);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                title: Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/welcome', (route) => false);
                  }
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                title: Text(
                  'Acerca de',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
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
    if (_loadingRole) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final colorScheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    // Opciones de menú según rol
    final List<Map<String, dynamic>> options =
        _role == 'admin'
            ? [
              {
                'label': 'Chat',
                'icon': Icons.chat,
                'color': Colors.blue,
                'route': 0,
              },
              {
                'label': 'Incidencias',
                'icon': Icons.report_problem,
                'color': Colors.orange,
                'route': 1,
              },
              {
                'label': 'Encuestas',
                'icon': Icons.poll,
                'color': Colors.purple,
                'route': 2,
              },
              {
                'label': 'Reservas',
                'icon': Icons.event_available,
                'color': Colors.teal,
                'route': 3,
              },
              {
                'label': 'Gestión de usuarios',
                'icon': Icons.manage_accounts,
                'color': Colors.indigo,
                'route': 4,
              },
              {
                'label': 'Instalaciones',
                'icon': Icons.home_work,
                'color': Colors.brown,
                'route': 5,
              },
              {
                'label': 'Notificaciones',
                'icon': Icons.notifications,
                'color': Colors.red,
                'route': 6,
              },
            ]
            : [
              {
                'label': 'Chat',
                'icon': Icons.chat,
                'color': Colors.blue,
                'route': 0,
              },
              {
                'label': 'Incidencias',
                'icon': Icons.report_problem,
                'color': Colors.orange,
                'route': 1,
              },
              {
                'label': 'Encuestas',
                'icon': Icons.poll,
                'color': Colors.purple,
                'route': 2,
              },
              {
                'label': 'Reservas',
                'icon': Icons.event_available,
                'color': Colors.teal,
                'route': 3,
              },
            ];
    final List<Widget> pages = _role == 'admin' ? _pagesAdmin : _pagesUser;
    if (_currentIndex < 0 || _currentIndex >= pages.length) {
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
                      radius: 32,
                      backgroundColor: colorScheme.primary.withOpacity(0.15),
                      child:
                          user?.email != null
                              ? Text(
                                user!.email![0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 28,
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                              : Icon(
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
                            user?.email != null &&
                                    user?.email!.isNotEmpty == true
                                ? '¡Hola, ${user?.email!.split('@')[0]}!'
                                : '¡Bienvenido!',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          if (_role != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    _role == 'admin'
                                        ? Colors.orange.withOpacity(0.2)
                                        : Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _role == 'admin' ? 'Administrador' : 'Usuario',
                                style: TextStyle(
                                  color:
                                      _role == 'admin'
                                          ? Colors.orange
                                          : Colors.blue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
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
              if (_role == 'admin')
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.apartment),
                    label: const Text('Gestionar Unidades'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/manage-units');
                    },
                  ),
                ),
              if (_role == 'admin')
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.mail_outline),
                    label: const Text('Invitar vecino a unidad'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/invite-resident');
                    },
                  ),
                ),
              if (_role == 'empresa')
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.business),
                    label: const Text('Crear comunidad'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/create-community');
                    },
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
                        return Material(
                          color: (opt['color'] as Color).withOpacity(0.13),
                          borderRadius: BorderRadius.circular(24),
                          elevation: 4,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              setState(() {
                                _currentIndex = opt['route'] as int;
                              });
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  opt['icon'] as IconData,
                                  size: 54,
                                  color: opt['color'] as Color,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  opt['label'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: colorScheme.onSurface,
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
        body: pages[_currentIndex],
      );
    }
  }
}
