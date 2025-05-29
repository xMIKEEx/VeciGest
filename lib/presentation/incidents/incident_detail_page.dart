import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vecigest/domain/models/incident_model.dart';
import 'package:vecigest/data/services/incident_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vecigest/data/services/user_role_service.dart';
import 'package:vecigest/presentation/incidents/new_incident_page.dart';

extension StringCap on String {
  String capitalize() => isEmpty ? this : this[0].toUpperCase() + substring(1);
}

class IncidentDetailPage extends StatefulWidget {
  final IncidentModel incident;
  const IncidentDetailPage({super.key, required this.incident});

  @override
  State<IncidentDetailPage> createState() => _IncidentDetailPageState();
}

class _IncidentDetailPageState extends State<IncidentDetailPage> {
  late String _selectedStatus;
  bool _loading = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.incident.status;
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
    final incident = widget.incident;
    final isOwner =
        FirebaseAuth.instance.currentUser?.uid == incident.createdBy;
    return Scaffold(
      appBar: AppBar(title: Text(incident.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Descripción', style: Theme.of(context).textTheme.titleMedium),
            Text(incident.description),
            const SizedBox(height: 8),
            Text('Creado por: ${incident.createdBy}'),
            Text(
              'Fecha: ${DateFormat.yMd().add_Hm().format(incident.createdAt)}',
            ),
            Text('Estado: ${incident.status}'),
            if (incident.photosUrls?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      incident.photosUrls!
                          .map(
                            (url) => Image.network(
                              url,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                          .toList(),
                ),
              ),
            if (_isAdmin || isOwner) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Editar estado',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        items:
                            ['open', 'in_progress', 'closed']
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s.capitalize()),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedStatus = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _loading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton.icon(
                            icon: const Icon(Icons.save),
                            label: const Text('Actualizar estado'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              setState(() => _loading = true);
                              await IncidentService().updateIncidentStatus(
                                incident.id,
                                _selectedStatus,
                              );
                              setState(() => _loading = false);
                              Navigator.pop(context, true);
                            },
                          ),
                    ],
                  ),
                ),
              ),
            ],
            if (_isAdmin) ...[
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => NewIncidentPage(incident: widget.incident),
                        ),
                      );
                      if (result == true) Navigator.pop(context, true);
                    },
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Eliminar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              title: const Text('Eliminar incidencia'),
                              content: const Text(
                                '¿Seguro que quieres eliminar esta incidencia?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                      );
                      if (confirm == true) {
                        await IncidentService().deleteIncident(
                          widget.incident.id,
                        );
                        if (mounted) Navigator.pop(context, true);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
