import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vecigest/data/services/incident_service.dart';
import 'package:vecigest/domain/models/incident_model.dart';
import 'package:vecigest/data/services/document_service.dart'; // For uploadIncidentPhoto
import 'dart:io';

class NewIncidentPage extends StatefulWidget {
  const NewIncidentPage({Key? key}) : super(key: key);

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
      final inc = IncidentModel(
        id: '', // Firestore will generate this
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        createdBy: user.uid,
        status: 'open', // Default status
        photosUrls: [], // Will be updated after upload
        createdAt: DateTime.now(),
        updatedAt: null,
        assignedTo: null,
      );
      final createdIncident = await _incidentService.createIncident(inc);
      // Subir fotos y actualizar URLs
      List<String> uploadedPhotoUrls = [];
      if (_pickedImages.isNotEmpty) {
        for (final file in _pickedImages) {
          // Assuming DocumentService.uploadIncidentPhoto handles file upload and returns URL
          // And that it takes incidentId and File as parameters.
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
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva incidencia')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(labelText: 'Título'),
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Introduce un título'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                        ),
                        maxLines: 4,
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Introduce una descripción'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickImages,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Añadir fotos'),
                          ),
                          const SizedBox(width: 12),
                          if (_pickedImages.isNotEmpty)
                            Expanded(
                              child: SizedBox(
                                height: 60,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _pickedImages.length,
                                  separatorBuilder:
                                      (_, __) => const SizedBox(width: 8),
                                  itemBuilder:
                                      (_, i) => ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(_pickedImages[i].path),
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Crear incidencia'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
