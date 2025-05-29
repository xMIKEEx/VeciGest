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

class IncidentListPage extends StatefulWidget {
  final Function(Widget)? onNavigate;

  const IncidentListPage({super.key, this.onNavigate});

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
                  if (widget.onNavigate != null) {
                    widget.onNavigate!(const NewIncidentPage());
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NewIncidentPage(),
                      ),
                    );
                  }
                },
                backgroundColor: colorScheme.primary,
                tooltip: 'Crear incidencia',
                child: const Icon(Icons.add),
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
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              itemCount: incidents.length,
              itemBuilder: (ctx, i) {
                final inc = incidents[i];
                return Card(
                  elevation: 6,
                  margin: const EdgeInsets.only(bottom: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  color: colorScheme.surfaceContainerHighest,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () {
                      if (widget.onNavigate != null) {
                        widget.onNavigate!(IncidentDetailPage(incident: inc));
                      } else {
                        Navigator.pushNamed(
                          ctx,
                          AppRoutes.incidentDetail,
                          arguments: inc,
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 22,
                        horizontal: 24,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.report_problem,
                            size: 32,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  inc.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  inc.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colorScheme.onSurface.withOpacity(
                                      0.7,
                                    ),
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Chip(
                                        label: Text(
                                          'Estado: ${inc.status}',
                                          style: TextStyle(
                                            color: colorScheme.onPrimary,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                        backgroundColor: colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: colorScheme.onSurface.withOpacity(
                                        0.6,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        DateFormat(
                                          'dd/MM/yyyy HH:mm',
                                        ).format(inc.createdAt),
                                        style: TextStyle(
                                          color: colorScheme.onSurface
                                              .withOpacity(0.6),
                                          fontFamily: 'Inter',
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right,
                            size: 32,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
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
