import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Este archivo está obsoleto. El registro de vecinos se realiza únicamente en RegisterNeighborPage.

class RegisterFromInvitePage extends StatefulWidget {
  final String communityId;
  final String unitId;
  final String token;
  const RegisterFromInvitePage({
    super.key,
    required this.communityId,
    required this.unitId,
    required this.token,
  });

  @override
  State<RegisterFromInvitePage> createState() => _RegisterFromInvitePageState();
}

class _RegisterFromInvitePageState extends State<RegisterFromInvitePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _success;
  bool _showPassword = false;

  Future<bool> _validateToken() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('communities')
            .doc(widget.communityId)
            .collection('units')
            .doc(widget.unitId)
            .get();
    final data = doc.data();
    return data != null &&
        data['inviteToken'] == widget.token &&
        data['residentEmail'] == null;
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      setState(() {
        _error = 'Las contraseñas no coinciden.';
        _isLoading = false;
      });
      return;
    }
    if (!await _validateToken()) {
      setState(() {
        _error = 'Invitación no válida o ya usada.';
        _isLoading = false;
      });
      return;
    }
    try {
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .collection('units')
          .doc(widget.unitId)
          .update({
            'residentEmail': _emailController.text.trim(),
            'residentUid': userCred.user!.uid,
            'inviteToken': null,
            'inviteEmail': null,
            'inviteSentAt': null,
          });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .set({
            'email': _emailController.text.trim(),
            'name': _nameController.text.trim(),
            'role': 'user',
            'communityId': widget.communityId,
            'unitId': widget.unitId,
            'createdAt': DateTime.now(),
          });
      setState(() {
        _success = 'Registro completado. Ya puedes acceder.';
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
      appBar: AppBar(title: const Text('Registro desde invitación')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed:
                      () => setState(() => _showPassword = !_showPassword),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar contraseña',
              ),
            ),
            const SizedBox(height: 24),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
            ],
            if (_success != null) ...[
              Text(_success!, style: const TextStyle(color: Colors.green)),
              const SizedBox(height: 8),
            ],
            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}
