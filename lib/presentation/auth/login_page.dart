import 'package:flutter/material.dart';
import 'package:vecigest/data/services/auth_service.dart';
import 'package:vecigest/data/services/user_role_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              // Logo y título
              _buildHeader(context, colorScheme),

              const SizedBox(height: 60),

              // Botones de acción
              _buildActionButtons(context, colorScheme),

              const SizedBox(height: 40),

              // Footer
              _buildFooter(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        // Logo container
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
          child: Image.asset(
            'assets/images/logo1.png',
            width: 80,
            height: 80,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 32),

        Text(
          'VeciGest',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Gestiona tu comunidad de manera inteligente',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        // Registro administrador
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/register');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
            label: const Text(
              'Crear nueva comunidad',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Login general
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.primary, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const _GeneralLoginForm()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: colorScheme.primary,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: Icon(Icons.login, color: colorScheme.primary),
            label: Text(
              'Iniciar sesión',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: Divider(color: colorScheme.onSurface.withOpacity(0.2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'o únete por invitación',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: colorScheme.onSurface.withOpacity(0.2)),
            ),
          ],
        ),

        const SizedBox(height: 20), // Unirse por token
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.secondary.withOpacity(0.3)),
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              _showTokenInputDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: colorScheme.secondary,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: Icon(Icons.group_add, color: colorScheme.secondary),
            label: Text(
              'Unirse con token de invitación',
              style: TextStyle(
                color: colorScheme.secondary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '¿Eres nuevo? Crea una comunidad como administrador o únete con una invitación.',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showTokenInputDialog(BuildContext context) {
    final tokenController = TextEditingController();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.key,
                    color: colorScheme.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Token de invitación',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Introduce el token de invitación que te proporcionó el administrador de tu comunidad.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: tokenController,
                  decoration: InputDecoration(
                    labelText: 'Token de invitación',
                    hintText: 'Pega aquí tu token',
                    prefixIcon: const Icon(Icons.vpn_key_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  autofocus: true,
                  textCapitalization: TextCapitalization.none,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.secondary,
                      colorScheme.secondary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () {
                    final token = tokenController.text.trim();
                    if (token.isNotEmpty) {
                      Navigator.of(context).pop();
                      Navigator.of(
                        context,
                      ).pushNamed('/invite-register', arguments: token);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor ingresa un token válido'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

// Formulario de login general
class _GeneralLoginForm extends StatefulWidget {
  const _GeneralLoginForm();

  @override
  State<_GeneralLoginForm> createState() => _GeneralLoginFormState();
}

class _GeneralLoginFormState extends State<_GeneralLoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _showPassword = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userCredential = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (userCredential.user != null && mounted) {
        final userRole = await UserRoleService().getUserRoleAndCommunity(
          userCredential.user!.uid,
        );

        if (userRole != null) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          setState(() {
            _error = 'Usuario no encontrado en la base de datos';
          });
        }
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
        title: const Text('Iniciar sesión'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Icono de login
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, size: 48, color: colorScheme.primary),
              ),

              const SizedBox(height: 32),

              Text(
                'Bienvenido de vuelta',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Ingresa tus credenciales para continuar',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 40),

              // Formulario
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
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

                      const SizedBox(height: 24),

                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
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
                                  : const Text(
                                    'Iniciar sesión',
                                    style: TextStyle(
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
    super.dispose();
  }
}
