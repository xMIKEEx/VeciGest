import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vecigest/domain/models/incident_model.dart';
import 'package:vecigest/data/services/incident_service.dart';

extension StringCap on String {
  String capitalize() => isEmpty ? this : this[0].toUpperCase() + substring(1);
}

class IncidentDetailPage extends StatefulWidget {
  final IncidentModel incident;
  const IncidentDetailPage({Key? key, required this.incident})
    : super(key: key);

  @override
  State<IncidentDetailPage> createState() => _IncidentDetailPageState();
}

class _IncidentDetailPageState extends State<IncidentDetailPage> {
  late String _selectedStatus;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.incident.status;
  }

  @override
  Widget build(BuildContext context) {
    final incident = widget.incident;
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
            if (incident.status != 'closed') ...[
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
                  if (val != null) setState(() => _selectedStatus = val);
                },
              ),
              const SizedBox(height: 12),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    child: const Text('Actualizar estado'),
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
          ],
        ),
      ),
    );
  }
}
