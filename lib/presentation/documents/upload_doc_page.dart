import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vecigest/data/services/document_service.dart';
import 'dart:io';

class UploadDocPage extends StatefulWidget {
  const UploadDocPage({super.key});

  @override
  State<UploadDocPage> createState() => _UploadDocPageState();
}

class _UploadDocPageState extends State<UploadDocPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _folderCtrl = TextEditingController();
  final DocumentService _documentService = DocumentService();
  File? _pickedFile;
  String? _pickedFileName;
  bool _loading = false;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _pickedFile = File(result.files.single.path!);
          _pickedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar archivo: $e')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _pickedFile == null) {
      if (_pickedFile == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Selecciona un archivo.')));
      }
      return;
    }
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');
      await _documentService.uploadDocument(
        _pickedFile!,
        folder: _folderCtrl.text.trim(),
        uploaderId: user.uid,
        name: _nameCtrl.text.trim(),
      );
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
    _nameCtrl.dispose();
    _folderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subir documento')),
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
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del documento',
                        ),
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Introduce un nombre'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _folderCtrl,
                        decoration: const InputDecoration(labelText: 'Carpeta'),
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Introduce una carpeta'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickFile,
                            icon: const Icon(Icons.attach_file),
                            label: const Text('Seleccionar archivo'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _pickedFileName ?? 'Ningún archivo seleccionado',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Subir documento'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
