import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vecigest/data/services/incident_service.dart';
import 'package:vecigest/domain/models/incident_model.dart';
import 'package:vecigest/data/services/document_service.dart';
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
    }
  }

  Future<void> _pickImages() async {
    try {
      final images = await _picker.pickMultiImage();
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
      if (user == null) throw 'Usuario no autenticado';
      List<String> uploadedPhotoUrls = [];
      if (_pickedImages.isNotEmpty) {
        for (final file in _pickedImages) {
          final url = await DocumentService.uploadIncidentPhoto(
            user.uid,
            File(file.path),
          );
          uploadedPhotoUrls.add(url);
        }
      }
      if (widget.incident == null) {
        // Create new incident
        final incident = IncidentModel(
          id: '',
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          status: 'open',
          createdAt: DateTime.now(),
          createdBy: user.uid,
          photosUrls: uploadedPhotoUrls,
        );
        await _incidentService.createIncident(incident);
      } else {
        // Update existing incident
        await _incidentService.updateIncidentFields(widget.incident!.id, {
          'title': _titleCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        if (uploadedPhotoUrls.isNotEmpty) {
          await _incidentService.updateIncidentPhotosUrls(widget.incident!.id, [
            ...?widget.incident!.photosUrls,
            ...uploadedPhotoUrls,
          ]);
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
    const redColor = Color(0xFFF44336);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 98, // Increased by 75% from standard 56px
        title: Text(
          isEdit ? 'Editar Incidencia' : 'Nueva Incidencia',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: redColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: redColor.withOpacity(0.3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                redColor,
                redColor.withOpacity(0.9),
                const Color(0xFFE53935),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
      ),
      backgroundColor: theme.colorScheme.surface,
      body: _buildBody(isEdit, theme, redColor),
    );
  }

  Widget _buildBody(bool isEdit, ThemeData theme, Color redColor) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Tarjeta de información básica
                Card(
                  elevation: 8,
                  shadowColor: redColor.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          redColor.withOpacity(0.1),
                          redColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: redColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.report_problem,
                                color: redColor,
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
                            hintText: 'Describe el problema brevemente...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: redColor, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(16),
                            labelStyle: TextStyle(color: redColor),
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
                            hintText: 'Explica detalladamente el problema...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: redColor, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(16),
                            labelStyle: TextStyle(color: redColor),
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
                ),
                const SizedBox(height: 16),

                // Tarjeta de fotos
                Card(
                  elevation: 8,
                  shadowColor: redColor.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey.withOpacity(0.1),
                          Colors.grey.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
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
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _pickedImages.length,
                              itemBuilder:
                                  (ctx, i) => Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: FileImage(
                                          File(_pickedImages[i].path),
                                        ),
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
                            backgroundColor: redColor.withOpacity(0.1),
                            foregroundColor: redColor,
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
                ),
                const SizedBox(height: 32),

                // Botón principal
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: redColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: redColor.withOpacity(0.3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isEdit ? Icons.save : Icons.send, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          isEdit ? 'Guardar Cambios' : 'Crear Incidencia',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
  }
}
