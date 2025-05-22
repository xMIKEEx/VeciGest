import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vecigest/domain/models/property_model.dart';
import 'package:vecigest/data/services/property_service.dart';

class PropertyListPage extends StatefulWidget {
  const PropertyListPage({super.key});

  @override
  State<PropertyListPage> createState() => _PropertyListPageState();
}

class _PropertyListPageState extends State<PropertyListPage> {
  late Future<String> _communityIdFuture;
  final PropertyService _propertyService = PropertyService();

  @override
  void initState() {
    super.initState();
    _communityIdFuture = _getUserCommunityId();
  }

  Future<String> _getUserCommunityId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Si no hay usuario, es un error y no se debería llegar aquí
      // si la navegación está protegida.
      // Devolvemos una cadena vacía y PropertyDetailPage mostrará su propio error.
      print('Error: Usuario no autenticado al intentar obtener communityId.');
      return '';
    }

    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    if (!userDoc.exists ||
        userDoc.data()?['communityId'] == null ||
        (userDoc.data()!['communityId'] as String).isEmpty) {
      // Si el usuario no tiene communityId o está vacío, es un error.
      // Devolvemos una cadena vacía y PropertyDetailPage mostrará su propio error.
      print(
        'Error: communityId no encontrado o vacío para el usuario ${user.uid}.',
      );
      return '';
    }
    return userDoc['communityId'] as String;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _communityIdFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: {snapshot.error}'));
        }
        final communityId = snapshot.data ?? '';
        if (communityId.isEmpty) {
          return const Center(
            child: Text('No se ha podido determinar la comunidad'),
          );
        }
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false, // Remove back arrow
            title: const Text(
              'Viviendas',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            elevation: 0, // Remove shadow for a more modern look
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            centerTitle: true, // Center the title for better aesthetics
            actions: [
              IconButton(
                icon: const Icon(Icons.mail),
                tooltip: 'Ver invitaciones',
                onPressed: () {
                  Navigator.pushNamed(context, '/invitations');
                },
              ),
            ],
          ),
          body: StreamBuilder<List<PropertyModel>>(
            stream: _propertyService.getProperties(communityId: communityId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: {snapshot.error}'));
              }
              final properties = snapshot.data ?? [];
              if (properties.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_work_outlined,
                        size: 80,
                        color: Theme.of(context).primaryColor.withOpacity(0.7),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'No hay viviendas registradas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Añade una vivienda para comenzar',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Añadir vivienda'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          final user = FirebaseAuth.instance.currentUser;
                          print('DEBUG: UID actual: \\${user?.uid}');
                          print(
                            'DEBUG: communityId que se pasa: \\$communityId',
                          );
                          Navigator.pushNamed(
                            context,
                            '/property-detail',
                            arguments: {'communityId': communityId},
                          );
                        },
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  // Header with actions
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Añadir vivienda'),
                            onPressed: () {
                              final user = FirebaseAuth.instance.currentUser;
                              print('DEBUG: UID actual: \\${user?.uid}');
                              print(
                                'DEBUG: communityId que se pasa: \\$communityId',
                              );
                              Navigator.pushNamed(
                                context,
                                '/property-detail',
                                arguments: {'communityId': communityId},
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.mail),
                          label: const Text('Invitaciones'),
                          onPressed: () {
                            Navigator.pushNamed(context, '/invitations');
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(130, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // List of properties
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 16, bottom: 24),
                      itemCount: properties.length,
                      itemBuilder: (context, index) {
                        final property = properties[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/property-detail',
                                arguments: {
                                  'property': property,
                                  'communityId': communityId,
                                  'showDetails':
                                      true, // Para distinguir modo detalle
                                },
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.home_rounded,
                                          color: Theme.of(context).primaryColor,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          property
                                              .number, // Use number as identifier
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      _buildPropertyMenu(
                                        context,
                                        property,
                                        communityId,
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  _buildPropertyStatusIndicator(property),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // Method to build the property status indicator
  Widget _buildPropertyStatusIndicator(PropertyModel property) {
    if (property.userId != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 16),
            SizedBox(width: 6),
            Text(
              'Asignada',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    } else if (property.additionalInfo?.containsKey('invitePending') == true &&
        property.additionalInfo!['invitePending'] == true) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule, color: Colors.orange, size: 16),
            SizedBox(width: 6),
            Text(
              'Invitación pendiente',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_off, color: Colors.grey, size: 16),
            SizedBox(width: 6),
            Text(
              'Sin asignar',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
  }

  // Method to build the property menu popup button
  Widget _buildPropertyMenu(
    BuildContext context,
    PropertyModel property,
    String communityId,
  ) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'edit') {
          Navigator.pushNamed(
            context,
            '/property-detail',
            arguments: {'property': property, 'communityId': communityId},
          );
        } else if (value == 'delete') {
          _showDeleteDialog(property, communityId);
        }
      },
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Eliminar', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
    );
  }

  void _showDeleteDialog(PropertyModel property, String communityId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar vivienda'),
            content: Text(
              '¿Estás seguro de que quieres eliminar la vivienda ${property.number}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await _propertyService.deleteProperty(
                      communityId,
                      property.viviendaId,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vivienda eliminada correctamente'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al eliminar: $e')),
                      );
                    }
                  }
                },
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }
}
