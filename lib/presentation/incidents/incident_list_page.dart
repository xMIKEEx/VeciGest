import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vecigest/data/services/incident_service.dart';
import 'package:vecigest/domain/models/incident_model.dart';
import 'package:vecigest/utils/routes.dart';
import 'package:vecigest/presentation/incidents/new_incident_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vecigest/data/services/user_role_service.dart';

class IncidentListPage extends StatefulWidget {
  const IncidentListPage({super.key});

  @override
  State<IncidentListPage> createState() => _IncidentListPageState();
}

class _IncidentListPageState extends State<IncidentListPage> {
  final IncidentService _incidentService = IncidentService();
  bool _isAdmin = false;

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      floatingActionButton:
          _isAdmin
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NewIncidentPage()),
                  );
                },
                backgroundColor: colorScheme.primary,
                child: const Icon(Icons.add),
                tooltip: 'Crear incidencia',
              )
              : null,
      body: Container(
        color: colorScheme.surface,
        child: StreamBuilder<List<IncidentModel>>(
          stream: _incidentService.getIncidents(),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                itemCount: 6,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                itemBuilder:
                    (_, __) => Shimmer.fromColors(
                      baseColor: colorScheme.surfaceContainerHighest,
                      highlightColor: colorScheme.surface,
                      child: Container(
                        height: 80,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
              );
            }
            if (snap.hasError) {
              return const Center(child: Text('Error al cargar incidencias'));
            }
            final incidents = snap.data ?? [];
            if (incidents.isEmpty) {
              return Center(
                child: Text(
                  'No hay incidencias registradas',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: incidents.length,
              itemBuilder: (ctx, i) {
                final inc = incidents[i];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 22,
                    ),
                    title: Text(
                      inc.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.report_problem,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Estado: ${inc.status}',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(inc.createdAt),
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 28),
                    onTap:
                        () => Navigator.pushNamed(
                          ctx,
                          AppRoutes.incidentDetail,
                          arguments: inc,
                        ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
