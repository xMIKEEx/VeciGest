import 'package:flutter/material.dart';
import 'package:vecigest/data/services/invite_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vecigest/data/services/user_service.dart';

class InviteRegisterPage extends StatefulWidget {
  final String token;
  const InviteRegisterPage({super.key, required this.token});

  @override
  State<InviteRegisterPage> createState() => _InviteRegisterPageState();
}

class _InviteRegisterPageState extends State<InviteRegisterPage> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _email;
  String? _vivienda;
  String? _role;
  String? _communityId;
  String? _inviteId;

  @override
  void initState() {
    super.initState();
    _loadInvite();
  }

  Future<void> _loadInvite() async {
    setState(() => _loading = true);
    final invite = await InviteService().getInviteByToken(widget.token);
    if (invite == null ||
        invite.used ||
        invite.expiresAt.isBefore(DateTime.now())) {
      setState(() {
        _error =
            invite == null
                ? 'Este enlace no es válido. Pide uno nuevo a tu administrador.'
                : invite.used
                ? 'Este enlace ya se usó. Solicita uno nuevo.'
                : 'Este enlace ya expiró. Solicita uno nuevo.';
        _loading = false;
      });
      return;
    }
    setState(() {
      _email = invite.email;
      _vivienda = invite.vivienda;
      _role = invite.role;
      _communityId = invite.communityId;
      _inviteId = invite.id;
      _loading = false;
    });
  }

  Future<void> _register() async {
    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }
    setState(() => _loading = true);
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _email!,
            password: _passwordCtrl.text.trim(),
          );
      final user = userCredential.user;
      if (user != null) {
        await UserService().createUserByRole(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.email?.split('@')[0] ?? '',
          communityId: _communityId!,
          role: _role ?? 'user',
          vivienda: _vivienda,
        );
        try {
          await InviteService().markInviteUsed(_inviteId!, user.uid);
        } catch (e) {
          setState(() => _error = e.toString().replaceAll('Exception: ', ''));
          // Elimina el usuario creado si la asignación falla
          await user.delete();
          return;
        }
      }
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
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
    return Scaffold(
      appBar: AppBar(title: const Text('Registro por invitación')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Te vas a registrar como ${_role == 'admin' ? 'co-admin' : 'vecino'} de la comunidad.',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (_vivienda != null && _vivienda!.isNotEmpty)
              Text(
                'Vivienda: $_vivienda',
                style: const TextStyle(fontSize: 16),
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
