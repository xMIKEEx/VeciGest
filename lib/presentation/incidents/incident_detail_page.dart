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

  String _getStatusInSpanish(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Abierta';
      case 'in_progress':
        return 'En progreso';
      case 'closed':
        return 'Cerrada';
      default:
        return status.capitalize();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'closed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final incident = widget.incident;
    final isOwner =
        FirebaseAuth.instance.currentUser?.uid == incident.createdBy;
    final theme = Theme.of(context);
    const redColor = Color(0xFFF44336);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 98, // Increased by 75% from standard 56px
        title: Text(
          incident.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: redColor,
        foregroundColor: Colors.white, // Ensures back arrow is white
        elevation: 8,
        shadowColor: redColor.withOpacity(0.3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [redColor, Color(0xFFE53935)],
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
      ),
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(theme, redColor, incident, isOwner),
            if (incident.photosUrls?.isNotEmpty ?? false) ...[
              const SizedBox(height: 16),
              _buildPhotoGallery(theme, incident),
            ],
            if (_isAdmin || isOwner) ...[
              const SizedBox(height: 16),
              _buildStatusEditor(theme, redColor, incident),
            ],
            if (_isAdmin) ...[
              const SizedBox(height: 16),
              _buildAdminButtons(redColor),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    ThemeData theme,
    Color redColor,
    IncidentModel incident,
    bool isOwner,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: redColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(color: redColor.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: redColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.report_problem, size: 16, color: redColor),
              ),
              const SizedBox(width: 8),
              Text(
                'Descripción',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            incident.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            Icons.person,
            'Creado por: ${incident.createdBy}',
            theme,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.access_time,
            'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(incident.createdAt)}',
            theme,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.flag,
                size: 18,
                color: _getStatusColor(widget.incident.status),
              ),
              const SizedBox(width: 8),
              Text(
                'Estado:',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(widget.incident.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusInSpanish(widget.incident.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoGallery(ThemeData theme, IncidentModel incident) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(color: Colors.blue.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.photo_library,
                  color: Colors.blue[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Fotografías',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: incident.photosUrls!.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Image.network(
                    incident.photosUrls![index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusEditor(
    ThemeData theme,
    Color redColor,
    IncidentModel incident,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: redColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(color: redColor.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: redColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.edit, color: redColor, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                'Editar estado',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            items:
                ['open', 'in_progress', 'closed']
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(_getStatusInSpanish(s)),
                      ),
                    )
                    .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedStatus = val);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child:
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Actualizar estado'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: redColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () async {
                        setState(() => _loading = true);
                        await IncidentService().updateIncidentStatus(
                          widget.incident.id,
                          _selectedStatus,
                        );
                        setState(() => _loading = false);
                        if (mounted) Navigator.pop(context, true);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminButtons(Color redColor) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Editar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: redColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NewIncidentPage(incident: widget.incident),
                ),
              );
              if (result == true && mounted) Navigator.pop(context, true);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                await IncidentService().deleteIncident(widget.incident.id);
                if (mounted) Navigator.pop(context, true);
              }
            },
          ),
        ),
      ],
    );
  }
}
