import 'package:flutter/material.dart';
import 'package:vecigest/data/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Campos para la vivienda del administrador
  final TextEditingController _viviendaNumberController =
      TextEditingController();
  final TextEditingController _viviendaPisoController = TextEditingController();
  final TextEditingController _viviendaPortalController =
      TextEditingController();
  final TextEditingController _viviendaInfoController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  void _register() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    if (_passwordController.text != _confirmController.text) {
      setState(() {
        _isLoading = false;
        _error = 'Las contraseñas no coinciden';
      });
      return;
    }
    if (_fullNameController.text.trim().isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'El nombre completo es obligatorio';
      });
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'El teléfono es obligatorio';
      });
      return;
    }

    if (_viviendaNumberController.text.trim().isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'El número de vivienda es obligatorio';
      });
      return;
    }

    if (_viviendaPisoController.text.trim().isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'El piso es obligatorio';
      });
      return;
    }

    try {
      // Solo creamos la cuenta de Firebase Auth
      final userCredential = await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      final user = userCredential.user;
      if (user != null && mounted) {
        // Debug: Verificar los datos antes de enviarlos
        final fullName = _fullNameController.text.trim();
        final phone = _phoneController.text.trim();
        final viviendaNumber = _viviendaNumberController.text.trim();
        final viviendaPiso = _viviendaPisoController.text.trim();
        final viviendaPortal = _viviendaPortalController.text.trim();
        final viviendaInfo = _viviendaInfoController.text.trim();

        print('DEBUG RegisterPage: fullName = "$fullName"');
        print('DEBUG RegisterPage: phone = "$phone"');
        print(
          'DEBUG RegisterPage: vivienda = "$viviendaNumber-$viviendaPiso-$viviendaPortal"',
        );

        // Llevamos al usuario a crear la comunidad, pasando los datos necesarios
        Navigator.of(context).pushReplacementNamed(
          '/create-community',
          arguments: {
            'userId': user.uid,
            'userEmail': user.email ?? '',
            'displayName': user.email?.split('@')[0] ?? '',
            'fullName': fullName,
            'phone': phone,
            'viviendaNumber': viviendaNumber,
            'viviendaPiso': viviendaPiso,
            'viviendaPortal': viviendaPortal,
            'viviendaInfo': viviendaInfo,
          },
        );
      }
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Crear Comunidad'),
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

              // Icono de administrador
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  size: 48,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Registro de Administrador',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Crea tu cuenta para gestionar una nueva comunidad',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Información importante
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Como administrador podrás gestionar usuarios, crear invitaciones y configurar los recursos de tu comunidad.',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

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
                        'Datos de la cuenta',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email de administrador',
                          hintText: 'admin@micomunidad.com',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          hintText: 'Mínimo 6 caracteres',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _confirmController,
                        obscureText: !_showConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirmar contraseña',
                          hintText: 'Repetir contraseña',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _showConfirmPassword = !_showConfirmPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      Text(
                        'Información personal',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),

                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          labelText: 'Nombre completo *',
                          hintText: 'Ej: Juan Pérez García',
                          prefixIcon: const Icon(Icons.person_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Teléfono *',
                          hintText: '+34 123 456 789',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),

                      const SizedBox(height: 32),

                      Text(
                        'Datos de tu vivienda',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Estos datos identificarán tu vivienda en la comunidad',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _viviendaNumberController,
                        decoration: InputDecoration(
                          labelText: 'Número/Letra *',
                          hintText: 'Ej: 2B, 101, etc.',
                          prefixIcon: const Icon(Icons.tag_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _viviendaPisoController,
                        decoration: InputDecoration(
                          labelText: 'Piso *',
                          hintText: 'Ej: 2, Planta Baja, etc.',
                          prefixIcon: const Icon(Icons.layers_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _viviendaPortalController,
                        decoration: InputDecoration(
                          labelText: 'Portal',
                          hintText: 'Ej: A, Edificio Principal, etc.',
                          prefixIcon: const Icon(Icons.apartment_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _viviendaInfoController,
                        decoration: InputDecoration(
                          labelText: 'Información complementaria',
                          hintText:
                              'Ej: Reformada en 2023, Ático con terraza...',
                          prefixIcon: const Icon(Icons.notes_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 2,
                        textInputAction: TextInputAction.done,
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
                              colorScheme.primary,
                              colorScheme.primary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon:
                              _isLoading
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
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                  ),
                          label: Text(
                            _isLoading
                                ? 'Creando cuenta...'
                                : 'Continuar con la configuración',
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _viviendaNumberController.dispose();
    _viviendaPisoController.dispose();
    _viviendaPortalController.dispose();
    _viviendaInfoController.dispose();
    super.dispose();
  }
}
