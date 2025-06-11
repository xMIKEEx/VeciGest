import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vecigest/data/services/incident_service.dart';
import 'package:vecigest/domain/models/incident_model.dart';
import 'package:vecigest/utils/routes.dart';
import 'package:vecigest/presentation/incidents/new_incident_page.dart';
import 'package:vecigest/presentation/incidents/incident_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vecigest/data/services/user_role_service.dart';
import 'package:vecigest/data/services/user_display_service.dart';

class IncidentListPage extends StatefulWidget {
  final Function(Widget)? onNavigate;

  const IncidentListPage({super.key, this.onNavigate});

  @override
  State<IncidentListPage> createState() => _IncidentListPageState();
}

class _IncidentListPageState extends State<IncidentListPage> {
  final IncidentService _incidentService = IncidentService();
  final UserDisplayService _userDisplayService = UserDisplayService();
  bool _isAdmin = false;

  // Cache for user display info
  final Map<String, Map<String, dynamic>> _userDisplayCache = {};

  @override
  void initState() {
    super.initState();
    _checkIfAdmin();
  }

  Future<void> _checkIfAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final role = await UserRoleService().getUserRoleAndCommunity(user.uid);
      if (role != null && role['role'] == 'admin') {
        setState(() => _isAdmin = true);
      }
    }
  }

  Future<Map<String, dynamic>?> _getUserDisplayInfo(String userId) async {
    // Check cache first
    if (_userDisplayCache.containsKey(userId)) {
      return _userDisplayCache[userId];
    }

    // Fetch from service
    final userInfo = await _userDisplayService.getUserDisplayInfo(userId);

    // Cache the result
    if (userInfo != null) {
      _userDisplayCache[userId] = userInfo;
    }

    return userInfo;
  }

  void _navigateToNewIncident() {
    if (widget.onNavigate != null) {
      widget.onNavigate!(const NewIncidentPage());
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NewIncidentPage()),
      );
    }
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'en progreso':
        return Colors.blue;
      case 'resuelto':
        return Colors.green;
      case 'cerrado':
        return Colors.grey;
      default:
        return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFFF5F5,
      ), // Light red background like detail page
      body: Stack(
        children: [
          // Main content with padding for floating header
          Padding(
            padding: const EdgeInsets.only(top: 286),
            child: _buildIncidentList(),
          ),
          // Floating header
          _buildFloatingHeader(),
        ],
      ),
    );
  }

  Widget _buildFloatingHeader() {
    const redColor = Color(0xFFF44336);

    return Positioned(
      top: 20,
      left: 16,
      right: 16,
      child: SafeArea(
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            height: 188,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  redColor,
                  redColor.withOpacity(0.9),
                  const Color(0xFFE53935),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              children: [
                // Elemento decorativo
                Positioned(
                  top: 10,
                  right: -20,
                  child: Icon(
                    Icons.report_problem,
                    size: 80,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                // Contenido principal
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Incidencias',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 28,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Reporta y gestiona incidencias',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Botón de crear incidencia (solo para admins)
                      if (_isAdmin)
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: _navigateToNewIncident,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: redColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              minimumSize: const Size(0, 34),
                            ),
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 16,
                            ),
                            label: const Text(
                              'Nueva Incidencia',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIncidentList() {
    return StreamBuilder<List<IncidentModel>>(
      stream: _incidentService.getIncidents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar incidencias'));
        }
        final incidents = snapshot.data ?? [];
        if (incidents.isEmpty) {
          return _buildEmptyState();
        }
        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            itemCount: incidents.length,
            itemBuilder:
                (context, index) => _buildIncidentCard(incidents[index]),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.builder(
      itemCount: 6,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      itemBuilder:
          (_, __) => Shimmer.fromColors(
            baseColor: colorScheme.surfaceContainerHighest,
            highlightColor: colorScheme.surface,
            child: Container(
              height: 120,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.report_problem_outlined,
            size: 64,
            color: colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay incidencias disponibles',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isAdmin
                ? 'Crea la primera incidencia usando el botón superior'
                : 'Las incidencias aparecerán aquí cuando sean creadas',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.4),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentCard(IncidentModel incident) {
    final theme = Theme.of(context);
    final cardColor = _getStatusColor(incident.status, theme.colorScheme);
    const redColor = Color(0xFFF44336);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3), // Changed to black shadow
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: redColor.withOpacity(0.1), width: 1),
          ),
          child: InkWell(
            onTap: () {
              print('DEBUG: Tapping incident ${incident.title}');
              if (widget.onNavigate != null) {
                print('DEBUG: Using onNavigate callback');
                widget.onNavigate!(IncidentDetailPage(incident: incident));
              } else {
                print('DEBUG: Using Navigator.pushNamed');
                Navigator.pushNamed(
                  context,
                  AppRoutes.incidentDetail,
                  arguments: incident,
                );
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIncidentHeader(theme, cardColor, incident),
                  const SizedBox(height: 16),
                  _buildIncidentContent(theme, incident),
                  const SizedBox(height: 16),
                  _buildIncidentActionButton(theme, cardColor, incident),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIncidentHeader(
    ThemeData theme,
    Color cardColor,
    IncidentModel incident,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF44336).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.report_problem,
            color: Color(0xFFF44336),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                incident.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd/MM/yyyy').format(incident.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        _buildIncidentStatusBadge(incident.status),
      ],
    );
  }

  Widget _buildIncidentStatusBadge(String status) {
    Color badgeColor;
    IconData icon;
    String text;

    switch (status.toLowerCase()) {
      case 'open':
        badgeColor = Colors.orange;
        icon = Icons.schedule;
        text = 'Abierta';
        break;
      case 'in_progress':
        badgeColor = Colors.blue;
        icon = Icons.hourglass_empty;
        text = 'En Progreso';
        break;
      case 'closed':
        badgeColor = Colors.green;
        icon = Icons.check_circle;
        text = 'Cerrada';
        break;
      default:
        badgeColor = Colors.grey;
        icon = Icons.help;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentContent(ThemeData theme, IncidentModel incident) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          incident.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.person,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>?>(
                future: _getUserDisplayInfo(incident.createdBy),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text(
                      'Cargando...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    );
                  }

                  final userInfo = snapshot.data;
                  final displayText = userInfo?['propertyDisplay'] ?? 'Usuario';

                  return Text(
                    'Creado por: $displayText',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
            if (incident.photosUrls?.isNotEmpty ?? false) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.photo_library,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                '${incident.photosUrls!.length} foto${incident.photosUrls!.length != 1 ? 's' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildIncidentActionButton(
    ThemeData theme,
    Color cardColor,
    IncidentModel incident,
  ) {
    if (incident.status.toLowerCase() == 'closed') {
      return const SizedBox.shrink();
    }

    const redColor = Color(0xFFF44336);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Always navigate to incident details, regardless of admin status
          if (widget.onNavigate != null) {
            widget.onNavigate!(IncidentDetailPage(incident: incident));
          } else {
            Navigator.pushNamed(
              context,
              AppRoutes.incidentDetail,
              arguments: incident,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: redColor, // Red button
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.visibility, size: 20),
        label: Text(
          incident.status.toLowerCase() == 'open'
              ? 'Ver Detalles'
              : 'Seguir Progreso',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
