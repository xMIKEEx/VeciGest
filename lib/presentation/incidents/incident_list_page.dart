import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vecigest/data/services/incident_service.dart';
import 'package:vecigest/domain/models/incident_model.dart';
import 'package:vecigest/utils/routes.dart';

class IncidentListPage extends StatefulWidget {
  const IncidentListPage({Key? key}) : super(key: key);

  @override
  State<IncidentListPage> createState() => _IncidentListPageState();
}

class _IncidentListPageState extends State<IncidentListPage> {
  final IncidentService _incidentService = IncidentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incidencias')),
      body: StreamBuilder<List<IncidentModel>>(
        stream: _incidentService.getIncidents(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(child: Text('Error al cargar incidencias'));
          }
          final incidents = snap.data ?? [];
          return ListView.separated(
            itemCount: incidents.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (ctx, i) {
              final inc = incidents[i];
              return ListTile(
                title: Text(inc.title),
                subtitle: Text(
                  'Estado: [4m${inc.status}[24m • ${DateFormat.yMd().add_Hm().format(inc.createdAt)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap:
                    () => Navigator.pushNamed(
                      ctx,
                      AppRoutes.incidentDetail,
                      arguments: inc,
                    ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.newIncident),
        child: const Icon(Icons.add),
        tooltip: 'Nueva incidencia',
      ),
    );
  }
}
