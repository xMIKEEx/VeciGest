import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Importa las páginas placeholder (ajusta los imports según tu estructura real)
import 'package:vecigest/presentation/chat/thread_list_page.dart'; // Changed import
import 'package:vecigest/presentation/incidents/incident_list_page.dart'; // Corrected path
import 'package:vecigest/presentation/documents/doc_list_page.dart'; // Corrected path
import 'package:vecigest/presentation/polls/poll_list_page.dart'; // Corrected path
import 'package:vecigest/presentation/reservations/reservation_list_page.dart'; // Nueva importación
import 'package:vecigest/presentation/properties/property_list_page.dart'; // Importación para propiedades
import 'package:vecigest/data/services/user_role_service.dart';
import 'package:vecigest/presentation/home/user_dashboard_page.dart';
import 'package:vecigest/presentation/auth/edit_community_page.dart';
import '../../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = -1;
  final List<Widget> _pages = const [
    ThreadListPage(),
    IncidentListPage(),
    DocListPage(),
    PollListPage(),
    ReservationListPage(),
    PropertyListPage(),
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
                          'ID: ${user.uid}',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        )
                        : null,
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const UserDashboardPage(),
                    ),
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
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/login');
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
              // Opción para editar comunidad (solo visible para admins)
              if (user != null)
                FutureBuilder<Map<String, dynamic>?>(
                  future: UserRoleService().getUserRoleAndCommunity(user.uid),
                  builder: (context, snapshot) {
                    final userRole = snapshot.data;
                    if (userRole != null && userRole['role'] == 'admin') {
                      return ListTile(
                        leading: Icon(
                          Icons.apartment,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        title: const Text('Editar comunidad'),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (_) => EditCommunityPage(
                                    communityId: userRole['communityId'],
                                  ),
                            ),
                          );
                        },
                      );
                    }
                    return Container();
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
    // Obtener el rol del usuario para ocultar viviendas si es residente
    return FutureBuilder<Map<String, dynamic>?>(
      future:
          user != null
              ? UserRoleService().getUserRoleAndCommunity(user.uid)
              : Future.value(null),
      builder: (context, snapshot) {
        final userRole = snapshot.data;
        // Opciones base
        final options = [
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
          {
            'label': 'Reservas',
            'icon': Icons.event_available,
            'color': Colors.teal,
            'route': 4,
          },
        ];
        // Solo admins ven el cuadrado de viviendas
        if (userRole != null && userRole['role'] != 'resident') {
          options.add({
            'label': 'Viviendas',
            'icon': Icons.apartment,
            'color': Colors.amber,
            'route': 5,
          });
        }
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
                          radius: 32,
                          backgroundColor: colorScheme.primary.withOpacity(
                            0.15,
                          ),
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
                  const SizedBox(height: 16),
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
            body: _pages[_currentIndex],
          );
        }
      },
    );
  }
}
