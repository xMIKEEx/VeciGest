import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecigest/domain/models/property_model.dart';
import 'package:vecigest/data/services/property_service.dart';

class PropertyDetailPage extends StatefulWidget {
  const PropertyDetailPage({super.key});

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final PropertyService _propertyService = PropertyService();

  // Controllers
  final _numberController = TextEditingController();
  final _floorController = TextEditingController();
  final _blockController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  // Property model for edit mode
  PropertyModel? _propertyModel;
  late String _communityId;
  bool _isLoading = false;
  String? _assignedUserEmail;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    print('DEBUG property_detail_page.dart: args = $args');

    if (args != null && args['communityId'] != null) {
      _communityId = args['communityId'] as String;

      if (args.containsKey('property')) {
        // Edit mode
        _propertyModel = args['property'] as PropertyModel;
        _numberController.text = _propertyModel!.number;
        _floorController.text = _propertyModel!.floor;
        _blockController.text = _propertyModel!.block;

        if (_propertyModel!.additionalInfo != null &&
            _propertyModel!.additionalInfo!.containsKey('notes')) {
          _additionalInfoController.text =
              _propertyModel!.additionalInfo!['notes'] as String;
        }

        // Load user email if property is assigned
        if (_propertyModel!.userId != null) {
          _loadUserEmail(_propertyModel!.userId!);
        }
      }
    } else {
      // Si no hay communityId, muestra un error y cierra la pantalla
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error: No se pudo determinar la comunidad. Inténtalo de nuevo.',
            ),
          ),
        );
        Navigator.of(context).pop();
      });
    }
  }

  Future<void> _loadUserEmail(String userId) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (userDoc.exists) {
        setState(() {
          _assignedUserEmail = userDoc['email'] as String?;
        });
      }
    } catch (e) {
      // Handle error silently
      print('Error loading user email: $e');
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _floorController.dispose();
    _blockController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _saveProperty() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay usuario autenticado')),
        );
        return;
      }

      final number = _numberController.text.trim();
      final floor = _floorController.text.trim();
      final block = _blockController.text.trim();
      final additionalInfo = {'notes': _additionalInfoController.text.trim()};

      if (_propertyModel == null) {
        // Create mode
        await _propertyService.createProperty(
          communityId: _communityId,
          number: number,
          floor: floor,
          block: block,
          size: 0,
          ownerId:
              user.uid, // Este podría ser diferente dependiendo de la lógica del negocio
          additionalInfo: additionalInfo,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vivienda creada correctamente')),
          );
          Navigator.pop(context);
        }
      } else {
        // Edit mode
        await _propertyService.updateProperty(_propertyModel!.id, {
          'number': number,
          'floor': floor,
          'block': block,
          'additionalInfo': additionalInfo,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vivienda actualizada correctamente')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = _propertyModel != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Editar vivienda' : 'Nueva vivienda'),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _numberController,
                        decoration: const InputDecoration(
                          labelText: 'Número/Letra',
                          hintText: 'Ej: 2B, 101, etc.',
                          prefixIcon: Icon(Icons.tag),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, introduce un número o letra';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _floorController,
                        decoration: const InputDecoration(
                          labelText: 'Planta',
                          hintText: 'Ej: 1, 2, Planta Baja, etc.',
                          prefixIcon: Icon(Icons.layers),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, introduce la planta';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _blockController,
                        decoration: const InputDecoration(
                          labelText: 'Bloque/Edificio (opcional)',
                          hintText: 'Ej: A, Edificio Principal, etc.',
                          prefixIcon: Icon(Icons.apartment),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _additionalInfoController,
                        decoration: const InputDecoration(
                          labelText: 'Notas adicionales (opcional)',
                          hintText: 'Ej: Reformada en 2023',
                          prefixIcon: Icon(Icons.notes),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Show assigned user info if available
                      if (isEditMode && _propertyModel!.userId != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Usuario asignado a esta vivienda',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _assignedUserEmail ??
                                    'Usuario ${_propertyModel!.userId}',
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.person_remove),
                                label: const Text('Desasignar usuario'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                onPressed: () => _showUnassignDialog(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: Icon(isEditMode ? Icons.save : Icons.add),
                        label: Text(
                          isEditMode ? 'Guardar cambios' : 'Crear vivienda',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _saveProperty,
                      ),
                      if (isEditMode) ...[
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.delete),
                          label: const Text('Eliminar vivienda'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: Colors.red,
                          ),
                          onPressed: () {
                            _showDeleteDialog(_propertyModel!);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
    );
  }

  void _showDeleteDialog(PropertyModel property) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar vivienda'),
            content: Text(
              '¿Estás seguro de que quieres eliminar la vivienda ${property.fullIdentifier}?',
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
                    await _propertyService.deleteProperty(property.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vivienda eliminada correctamente'),
                        ),
                      );
                      Navigator.pop(context); // Return to property list
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

  void _showUnassignDialog() {
    if (_propertyModel == null || _propertyModel!.userId == null) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Desasignar usuario'),
            content: Text(
              '¿Estás seguro de que quieres desasignar al usuario ${_assignedUserEmail ?? _propertyModel!.userId} de esta vivienda?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  setState(() => _isLoading = true);

                  try {
                    await _propertyService.unassignUserFromProperty(
                      _propertyModel!.id,
                    );

                    setState(() {
                      _propertyModel = _propertyModel!.copyWith(userId: null);
                      _assignedUserEmail = null;
                      _isLoading = false;
                    });

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Usuario desasignado correctamente'),
                        ),
                      );
                    }
                  } catch (e) {
                    setState(() => _isLoading = false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al desasignar: $e')),
                      );
                    }
                  }
                },
                child: const Text('Desasignar'),
              ),
            ],
          ),
    );
  }
}
