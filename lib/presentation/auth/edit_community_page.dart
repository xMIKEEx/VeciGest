import 'package:flutter/material.dart';
import 'package:vecigest/data/services/community_service.dart';

class EditCommunityPage extends StatefulWidget {
  final String communityId;
  const EditCommunityPage({super.key, required this.communityId});

  @override
  State<EditCommunityPage> createState() => _EditCommunityPageState();
}

class _EditCommunityPageState extends State<EditCommunityPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCommunity();
  }

  Future<void> _loadCommunity() async {
    setState(() => _loading = true);
    try {
      // Suponiendo que tienes un CommunityService con getCommunityById
      final community = await CommunityService().getCommunityById(widget.communityId);
      if (community != null) {
        _nameCtrl.text = community.name;
        _addressCtrl.text = community.address;
        _emailCtrl.text = community.contactEmail;
      }
    } catch (e) {
      setState(() => _error = 'Error al cargar la comunidad: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await CommunityService().updateCommunity(
        id: widget.communityId,
        name: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        contactEmail: _emailCtrl.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _error = 'Error al actualizar la comunidad: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar comunidad')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre de la comunidad'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email de contacto'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Guardar cambios'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
