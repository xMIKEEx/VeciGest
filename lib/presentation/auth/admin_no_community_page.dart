import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminNoCommunityPage extends StatelessWidget {
  const AdminNoCommunityPage({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Recibe los argumentos del usuario si existen
    final args = ModalRoute.of(context)?.settings.arguments;
    Map<String, dynamic>? userArgs;
    if (args != null && args is Map<String, dynamic>) {
      userArgs = args;
      print('DEBUG: AdminNoCommunityPage recibió argumentos: $userArgs');
    } else {
      print('DEBUG: AdminNoCommunityPage no recibió argumentos');
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Configuración inicial'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icono principal
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primary,
                            colorScheme.primary.withOpacity(0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.home_work,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 40),

                    Text(
                      '¡Último paso!',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Crea tu comunidad para comenzar',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withOpacity(
                          0.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: colorScheme.primary,
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Como administrador, necesitas configurar una comunidad para poder gestionar a los vecinos, crear invitaciones y administrar los recursos.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.8),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Botón principal
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.primary.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          print('DEBUG: Botón Crear comunidad ahora pulsado');
                          if (userArgs != null) {
                            print(
                              'DEBUG: Navegando a /create-community con argumentos: $userArgs',
                            );
                            Navigator.of(context).pushNamed(
                              '/create-community',
                              arguments: userArgs,
                            );
                          } else {
                            // Fallback: obtener usuario actual
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              print(
                                'DEBUG: Fallback, navegando a /create-community con usuario actual',
                              );
                              Navigator.of(context).pushNamed(
                                '/create-community',
                                arguments: {
                                  'userId': user.uid,
                                  'userEmail': user.email,
                                  'displayName': user.displayName,
                                },
                              );
                            } else {
                              print(
                                'DEBUG: Fallback, sin usuario, navegando a /login',
                              );
                              Navigator.of(
                                context,
                              ).pushReplacementNamed('/login');
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 24,
                        ),
                        label: const Text(
                          'Crear mi comunidad',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Footer con botón secundario
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).pushNamed('/login');
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    Icons.arrow_back,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  label: Text(
                    'Volver al inicio de sesión',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
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
