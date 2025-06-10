import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vecigest/data/services/incident_service.dart';
import 'package:vecigest/domain/models/incident_model.dart';
import 'package:vecigest/data/services/document_service.dart'; // For uploadIncidentPhoto
import 'dart:io';

class NewIncidentPage extends StatefulWidget {
  final IncidentModel? incident;
  const NewIncidentPage({super.key, this.incident});

  @override
  State<NewIncidentPage> createState() => _NewIncidentPageState();
}

class _NewIncidentPageState extends State<NewIncidentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final IncidentService _incidentService = IncidentService();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _pickedImages = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.incident != null) {
      _titleCtrl.text = widget.incident!.title;
      _descCtrl.text = widget.incident!.description;
      // NOTA: No se precargan imágenes ya subidas, solo las nuevas
    }
  }

  Future<void> _pickImages() async {
    try {
      final images = await _picker.pickMultiImage();
      // Removed redundant null check for images, as pickMultiImage returns an empty list if no images are picked.
      if (images.isNotEmpty) {
        setState(() {
          _pickedImages = images;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imágenes: $e')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');
      if (widget.incident == null) {
        // Crear nueva incidencia
        final inc = IncidentModel(
          id: '',
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          createdBy: user.uid,
          status: 'open',
          photosUrls: [],
          createdAt: DateTime.now(),
          updatedAt: null,
          assignedTo: null,
        );
        final createdIncident = await _incidentService.createIncident(inc);
        // Subir fotos y actualizar URLs
        List<String> uploadedPhotoUrls = [];
        if (_pickedImages.isNotEmpty) {
          for (final file in _pickedImages) {
            final url = await DocumentService.uploadIncidentPhoto(
              createdIncident.id,
              File(file.path),
            );
            uploadedPhotoUrls.add(url);
          }
          if (uploadedPhotoUrls.isNotEmpty) {
            await _incidentService.updateIncidentPhotosUrls(
              createdIncident.id,
              uploadedPhotoUrls,
            );
          }
        }
      } else {
        // Editar incidencia existente
        await _incidentService.updateIncidentFields(widget.incident!.id, {
          'title': _titleCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'updatedAt': DateTime.now(),
        });
        // Subir nuevas fotos si las hay
        if (_pickedImages.isNotEmpty) {
          List<String> uploadedPhotoUrls = [];
          for (final file in _pickedImages) {
            final url = await DocumentService.uploadIncidentPhoto(
              widget.incident!.id,
              File(file.path),
            );
            uploadedPhotoUrls.add(url);
          }
          if (uploadedPhotoUrls.isNotEmpty) {
            await _incidentService.updateIncidentPhotosUrls(
              widget.incident!.id,
              [...?widget.incident!.photosUrls, ...uploadedPhotoUrls],
            );
          }
        }
      }
      setState(() => _loading = false);
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.incident != null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: null, // Remove VeciGest navigation bar with settings button
      backgroundColor: theme.colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 140,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    isEdit ? 'Editar Incidencia' : 'Nueva Incidencia',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 40,
                          right: -20,
                          child: Icon(
                            Icons.report_problem_outlined,
                            size: 100,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        Positioned(
                          bottom: 50,
                          left: 56,
                          child: Text(
                            isEdit
                                ? 'Edita la incidencia'
                                : 'Crea una nueva incidencia',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
        body:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Tarjeta de información básica
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.purple.withOpacity(0.1),
                                Colors.purple.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.report_problem,
                                      color: Colors.purple[600],
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Información de la Incidencia',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _titleCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Título',
                                  hintText:
                                      'Describe el problema brevemente...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                                validator:
                                    (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Introduce un título'
                                            : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _descCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Descripción',
                                  hintText:
                                      'Explica detalladamente el problema...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                                maxLines: 4,
                                validator:
                                    (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Introduce una descripción'
                                            : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tarjeta de fotos
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.blue.withOpacity(0.1),
                                Colors.blue.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
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
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (_pickedImages.isNotEmpty) ...[
                                SizedBox(
                                  height: 100,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _pickedImages.length,
                                    separatorBuilder:
                                        (_, __) => const SizedBox(width: 12),
                                    itemBuilder:
                                        (_, i) => ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Image.file(
                                              File(_pickedImages[i].path),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              ElevatedButton.icon(
                                onPressed: _pickImages,
                                icon: const Icon(Icons.add_photo_alternate),
                                label: Text(
                                  _pickedImages.isEmpty
                                      ? 'Añadir fotos'
                                      : 'Cambiar fotos',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[600],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Botón principal
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isEdit ? Icons.save : Icons.send,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  isEdit
                                      ? 'Guardar Cambios'
                                      : 'Crear Incidencia',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
