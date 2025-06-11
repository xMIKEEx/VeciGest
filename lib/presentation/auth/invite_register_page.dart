import 'package:flutter/material.dart';
import 'package:vecigest/data/services/invite_service.dart';
import 'package:vecigest/data/services/property_service.dart';
import 'package:vecigest/domain/models/property_model.dart';
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
  PropertyModel? _propertyDetails;
  final PropertyService _propertyService = PropertyService();

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
      // Load property details for better display
      _loadPropertyDetails();
    } catch (e) {
      setState(() {
        _error = 'Error al validar el token: $e';
        _loading = false;
      });
    }
  }

  Future<void> _loadPropertyDetails() async {
    if (_communityId != null && _viviendaId != null) {
      try {
        final property = await _propertyService.getPropertyById(
          _communityId!,
          _viviendaId!,
        );
        if (property != null) {
          setState(() {
            _propertyDetails = property;
          });
        }
      } catch (e) {
        print('Error loading property details: $e');
      }
    }
  }

  String _formatPropertyDisplay() {
    if (_propertyDetails != null) {
      final parts = <String>[];

      if (_propertyDetails!.number.isNotEmpty) {
        parts.add(_propertyDetails!.number);
      }
      if (_propertyDetails!.portal.isNotEmpty &&
          _propertyDetails!.portal != 'N/A') {
        parts.add('portal ${_propertyDetails!.portal}');
      }

      if (_propertyDetails!.piso.isNotEmpty &&
          _propertyDetails!.piso != 'N/A') {
        parts.add('piso ${_propertyDetails!.piso}');
      }

      return parts.isNotEmpty ? parts.join(' ') : 'Vivienda asignada';
    }
    return 'Cargando datos de vivienda...';
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

        // Marcar el token como usado (esto también asigna el usuario a la vivienda)
        await InviteService().markInviteUsed(_inviteId!, user.uid);

        // Redirigir al home page
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_loading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Validando invitación...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: const Text('Registro por invitación'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error de invitación',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Volver'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Registro por invitación'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Icono de invitación
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.secondary,
                      colorScheme.secondary.withOpacity(0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.secondary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.group_add,
                  size: 48,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Únete a la comunidad',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Completa tu registro para formar parte de la comunidad',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Card de información de la vivienda
              if (_viviendaId != null && _viviendaId!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer.withOpacity(0.3),
                        colorScheme.primaryContainer.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.home,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vivienda asignada',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatPropertyDisplay(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Formulario
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Datos personales',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (_email == null || _email!.isEmpty) ...[
                        TextFormField(
                          onChanged: (value) => _email = value.trim(),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'tu@email.com',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                      ],

                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Nombre completo',
                          hintText: 'Tu nombre y apellidos',
                          prefixIcon: const Icon(Icons.person_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _phoneCtrl,
                        decoration: InputDecoration(
                          labelText: 'Teléfono',
                          hintText: '+34 123 456 789',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _passwordCtrl,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          hintText: 'Mínimo 6 caracteres',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _confirmCtrl,
                        decoration: InputDecoration(
                          labelText: 'Confirmar contraseña',
                          hintText: 'Repetir contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        obscureText: true,
                      ),

                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.secondary,
                              colorScheme.secondary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.secondary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _loading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon:
                              _loading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  ),
                          label: Text(
                            _loading ? 'Registrando...' : 'Completar registro',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
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
    );
  }
}
