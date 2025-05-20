import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/unit_service.dart';
import '../../services/invitation_service.dart';

class RegisterNeighborPage extends StatefulWidget {
  const RegisterNeighborPage({super.key});

  @override
  State<RegisterNeighborPage> createState() => _RegisterNeighborPageState();
}

class _RegisterNeighborPageState extends State<RegisterNeighborPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  final UnitService unitService = UnitService();
  final InvitationService invitationService = InvitationService();

  Future<void> _registerWithToken() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final invitation = await invitationService.getInvitationByToken(
        _tokenController.text.trim(),
      );
      if (invitation == null ||
          invitation.estado != 'pendiente' ||
          invitation.expiracion.isBefore(DateTime.now())) {
        setState(() {
          _error = 'Invitación no válida o expirada.';
          _isLoading = false;
        });
        return;
      }
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      // Asignar usuario a la unidad
      await unitService.assignUserToUnit(
        invitation.unidadId,
        userCred.user!.email!,
      );
      // Marcar invitación como aceptada
      await invitationService.acceptInvitation(invitation.id);
      if (mounted) Navigator.of(context).pop();
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
      appBar: AppBar(title: const Text('Registro de Vecino')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator:
                    (v) =>
                        v == null || v.length < 6
                            ? 'Mínimo 6 caracteres'
                            : null,
              ),
              const SizedBox(height: 16),
              const Text('Registro con invitación'),
              TextFormField(
                controller: _tokenController,
                decoration: const InputDecoration(
                  labelText:
                      'Token de invitación (proporcionado por el administrador)',
                  hintText: 'Introduce el token recibido para tu vivienda',
                ),
                validator:
                    (v) =>
                        v == null || v.isEmpty
                            ? 'El token es obligatorio'
                            : null,
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : _registerWithToken,
                child: const Text('Registrarse'),
              ),
              const Divider(),
              const Text('¿Olvidaste tu contraseña?'),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/password-reset');
                },
                child: const Text('Recuperar contraseña'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
