import 'package:flutter/material.dart';
import 'package:vecigest/data/services/community_service.dart';

class CreateCommunityPage extends StatefulWidget {
  const CreateCommunityPage({super.key});

  @override
  State<CreateCommunityPage> createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  final CommunityService _communityService = CommunityService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _adminKeyController = TextEditingController();
  bool _isLoading = false;
  String? _result;
  String? _error;

  void _createCommunity() async {
    setState(() {
      _isLoading = true;
      _result = null;
      _error = null;
    });
    try {
      final adminKey = _adminKeyController.text.trim();
      if (adminKey.isEmpty) {
        setState(() {
          _error = 'Debes introducir una clave admin.';
          _isLoading = false;
        });
        return;
      }
      final id = await _communityService.createCommunity({
        'name': _nameController.text.trim(),
        'adminKey': adminKey,
        'createdAt': DateTime.now(),
      });
      setState(() {
        _result = 'Comunidad creada. Clave admin: $adminKey\nID: $id';
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear comunidad')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre comunidad'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _adminKeyController,
              decoration: const InputDecoration(
                labelText: 'Clave admin (única)',
              ),
            ),
            const SizedBox(height: 24),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
            ],
            if (_result != null) ...[
              Text(_result!, style: const TextStyle(color: Colors.green)),
              const SizedBox(height: 8),
            ],
            ElevatedButton(
              onPressed: _isLoading ? null : _createCommunity,
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Crear comunidad'),
            ),
          ],
        ),
      ),
    );
  }
}
