import 'package:flutter/material.dart';
import 'package:vecigest/data/services/invite_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InviteRegisterPage extends StatefulWidget {
  final String token;
  const InviteRegisterPage({super.key, required this.token});

  @override
  State<InviteRegisterPage> createState() => _InviteRegisterPageState();
}

class _InviteRegisterPageState extends State<InviteRegisterPage> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _nameCtrl = TextEditingController(); // Nuevo campo
  final _phoneCtrl = TextEditingController(); // Nuevo campo
  bool _loading = false;
  String? _error;
  String? _email; // El email ya no viene del token, solo se pide al usuario
  String? _viviendaId; // Renombrado
  String? _communityId;
  String? _inviteId;

  @override
  void initState() {
    super.initState();
    // Debug print to verify received token
    print('[DEBUG] InviteRegisterPage received token: "${widget.token}"');
    // Solo cargar el registro si el token no está vacío
    if (widget.token.trim().isNotEmpty) {
      _loadInvite();
    } else {
      setState(() {
        _error = 'El token no puede estar vacío.';
      });
    }
  }

  Future<void> _loadInvite() async {
    setState(() => _loading = true);
    try {
      final token = widget.token.trim();
      if (token.isEmpty) {
        setState(() {
          _error = 'El token no puede estar vacío.';
          _loading = false;
        });
        return;
      }
      final invite = await InviteService().getInviteByToken(token);
      if (invite == null || invite.used) {
        setState(() {
          _error =
              invite == null
                  ? 'Este enlace no es válido. Pide uno nuevo a tu administrador.'
                  : 'Este enlace ya se usó. Solicita uno nuevo.';
          _loading = false;
        });
        return;
      }
      // Ya no se asigna _email desde el token
      setState(() {
        _viviendaId = invite.viviendaId;
        _communityId = invite.communityId;
        _inviteId = invite.id;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al validar el token: $e';
        _loading = false;
      });
    }
  }

  Future<void> _register() async {
    final emailToUse = _email?.trim();
    if (emailToUse == null || emailToUse.isEmpty) {
      setState(() => _error = 'El email no puede estar vacío');
      return;
    }
    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'El nombre es obligatorio');
      return;
    }
    setState(() => _loading = true);
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailToUse,
            password: _passwordCtrl.text.trim(),
          );
      final user = userCredential.user;
      if (user != null) {
        // Crear perfil de usuario resident
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameCtrl.text.trim(),
          'email': user.email ?? '',
          'role': 'resident',
          'communityId': _communityId!,
          'viviendaId': _viviendaId!,
          'phone': _phoneCtrl.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        // Asignar userId a la vivienda
        await FirebaseFirestore.instance
            .collection('communities')
            .doc(_communityId)
            .collection('viviendas')
            .doc(_viviendaId)
            .update({'userId': user.uid});
        // Marcar el token como usado
        await InviteService().markInviteUsed(_inviteId!, user.uid);
        // Redirigir temporalmente al home page aunque sea residente
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home_page');
        }
        return;
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Registro por invitación')),
        body: Center(
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      );
    }
    // Si no hay error y no está cargando, mostrar el formulario de registro
    return Scaffold(
      appBar: AppBar(title: const Text('Registro por invitación')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Te vas a registrar como vecino de la comunidad.',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (_viviendaId != null && _viviendaId!.isNotEmpty)
              Text(
                'Vivienda asignada: $_viviendaId',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            const SizedBox(height: 16),
            if (_email == null || _email!.isEmpty) ...[
              TextField(
                onChanged: (value) => _email = value.trim(),
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordCtrl,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmCtrl,
              decoration: const InputDecoration(
                labelText: 'Confirmar contraseña',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}
