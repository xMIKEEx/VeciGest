import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecigest/domain/models/invite_model.dart';
import 'package:vecigest/data/services/invite_service.dart';
import 'package:vecigest/data/services/property_service.dart';

class InvitationsListPage extends StatefulWidget {
  const InvitationsListPage({super.key});

  @override
  State<InvitationsListPage> createState() => _InvitationsListPageState();
}

class _InvitationsListPageState extends State<InvitationsListPage> {
  late Future<String> _communityIdFuture;
  final InviteService _inviteService = InviteService();
  final PropertyService _propertyService = PropertyService();

  @override
  void initState() {
    super.initState();
    _communityIdFuture = _getUserCommunityId();
  }

  Future<String> _getUserCommunityId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay usuario autenticado')),
      );
      return '';
    }

    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    return userDoc['communityId'] as String;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _communityIdFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Invitaciones')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final communityId = snapshot.data ?? '';
        if (communityId.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Invitaciones')),
            body: const Center(
              child: Text('No se ha podido determinar la comunidad'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Invitaciones activas')),
          body: StreamBuilder<List<InviteModel>>(
            stream: _inviteService.getActiveInvites(communityId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final invites = snapshot.data ?? [];
              if (invites.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.mail, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay invitaciones activas',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Puedes invitar usuarios desde la pantalla principal',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: invites.length,
                itemBuilder: (context, index) {
                  final invite = invites[index];

                  // Get property info if this is a property invitation
                  return FutureBuilder<String>(
                    future: _getPropertyInfo(communityId, invite.viviendaId),
                    builder: (context, propertySnapshot) {
                      final propertyInfo = propertySnapshot.data ?? '';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: Icon(
                            invite.role == 'admin'
                                ? Icons.admin_panel_settings
                                : Icons.home,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: Text('Invitación'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rol: ${invite.role == 'admin' ? 'Administrador' : 'Usuario'}',
                              ),
                              if (invite.role == 'resident' &&
                                  propertyInfo.isNotEmpty)
                                Text('Vivienda: $propertyInfo'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showCancelDialog(invite),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<String> _getPropertyInfo(String communityId, String viviendaId) async {
    if (viviendaId.isEmpty) return '';

    try {
      final property = await _propertyService.getPropertyById(
        communityId,
        viviendaId,
      );
      if (property != null) {
        return property.number;
      }
    } catch (e) {
      print('Error getting property info: $e');
    }

    return '';
  }

  void _showCancelDialog(InviteModel invite) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancelar invitación'),
            content: Text(
              '¿Estás seguro de que quieres cancelar esta invitación?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await _inviteService.cancelInvite(invite.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invitación cancelada')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                child: const Text('Sí, cancelar'),
              ),
            ],
          ),
    );
  }
}
