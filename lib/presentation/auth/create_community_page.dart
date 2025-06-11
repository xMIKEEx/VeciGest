import 'package:flutter/material.dart';
import 'package:vecigest/data/services/community_service.dart';
import 'package:vecigest/data/services/user_service.dart';
import 'package:vecigest/data/services/property_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateCommunityPage extends StatefulWidget {
  const CreateCommunityPage({super.key});

  @override
  State<CreateCommunityPage> createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _resourceCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  final List<String> _resources =
      []; // Propiedades para el usuario administrador
  String? _userId;
  String? _userEmail;
  String? _displayName;
  String? _fullName;
  String? _phone;
  String? _viviendaNumber;
  String? _viviendaPiso;
  String? _viviendaPortal;
  String? _viviendaInfo;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    // Debug: Verificar los argumentos recibidos
    print('DEBUG CreateCommunity - args: $args');
    print('DEBUG CreateCommunity - args type: ${args.runtimeType}');
    if (args != null && args is Map<String, dynamic>) {
      _userId = args['userId'];
      _userEmail = args['userEmail'];
      _displayName = args['displayName'];
      _fullName = args['fullName'];
      _phone = args['phone'];
      _viviendaNumber = args['viviendaNumber'];
      _viviendaPiso = args['viviendaPiso'];
      _viviendaPortal = args['viviendaPortal'];
      _viviendaInfo = args['viviendaInfo'];

      // Debug: Verificar los datos recibidos
      print('DEBUG CreateCommunity - fullName: "$_fullName"');
      print('DEBUG CreateCommunity - phone: "$_phone"');
      print(
        'DEBUG CreateCommunity - vivienda: "$_viviendaNumber-$_viviendaPiso-$_viviendaPortal"',
      );

      if (_userEmail != null && _emailCtrl.text.isEmpty) {
        _emailCtrl.text = _userEmail!;
      }
    } else {
      print('DEBUG CreateCommunity - args is null or not Map<String, dynamic>');
      // Fallback: obtener usuario actual de FirebaseAuth
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _userId = user.uid;
        _userEmail = user.email;
        _displayName = user.displayName ?? user.email?.split('@')[0];
        if (_userEmail != null && _emailCtrl.text.isEmpty) {
          _emailCtrl.text = _userEmail!;
        }
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final community = await CommunityService().createCommunity(
        name: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        contactEmail: _emailCtrl.text.trim(),
        createdBy: _userId!,
        resources: _resources,
      ); // Asociar el usuario admin a la comunidad creada
      if (_userId != null && _userEmail != null && _displayName != null) {
        // Debug: Verificar datos antes de crear usuario y vivienda
        print('DEBUG CreateCommunity - Before createAdminUser:');
        print('  fullName: "$_fullName"');
        print('  phone: "$_phone"');
        print('  vivienda: "$_viviendaNumber-$_viviendaPiso-$_viviendaPortal"');

        // 1. Crear la vivienda del administrador
        final property = await PropertyService().createProperty(
          communityId: community.id,
          number: _viviendaNumber ?? '',
          piso: _viviendaPiso ?? '',
          portal: _viviendaPortal ?? '',
          size: 0, // Tamaño por defecto
          ownerId: _userId!,
          userId: _userId!, // El admin se asigna a su propia vivienda
          informacionComplementaria:
              _viviendaInfo?.isNotEmpty == true ? _viviendaInfo : null,
        );

        // 2. Crear el usuario administrador con referencia a su vivienda
        await UserService().createUserByRole(
          uid: _userId!,
          email: _userEmail!,
          displayName: _displayName!,
          communityId: community.id,
          role: 'admin',
          fullName: _fullName,
          phone: _phone,
          viviendaId: property.viviendaId,
          housing:
              property
                  .fullIdentifier, // Usar el identificador completo de la vivienda
        );

        // Navegar a la home
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        setState(() {
          _error = 'Faltan datos de usuario para asociar admin a comunidad';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al crear la comunidad: ${e.toString()}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _addResource() {
    if (_resourceCtrl.text.trim().isNotEmpty) {
      setState(() {
        _resources.add(_resourceCtrl.text.trim());
        _resourceCtrl.clear();
      });
    }
  }

  void _removeResource(int index) {
    setState(() {
      _resources.removeAt(index);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    _resourceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Configurar Comunidad'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Header con icono
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withOpacity(0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.home_work,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: Text(
                    'Configuración de tu comunidad',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    'Define la información básica y los recursos disponibles',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 32),

                // Card de información básica
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
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Información básica',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _nameCtrl,
                          decoration: InputDecoration(
                            labelText: 'Nombre de la comunidad',
                            hintText: 'Ej: Residencial Los Pinos',
                            prefixIcon: const Icon(Icons.apartment_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator:
                              (v) =>
                                  v == null || v.trim().isEmpty
                                      ? 'Campo obligatorio'
                                      : null,
                        ),

                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _addressCtrl,
                          decoration: InputDecoration(
                            labelText: 'Dirección completa',
                            hintText: 'Calle, número, ciudad, código postal',
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator:
                              (v) =>
                                  v == null || v.trim().isEmpty
                                      ? 'Campo obligatorio'
                                      : null,
                          maxLines: 2,
                        ),

                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _emailCtrl,
                          decoration: InputDecoration(
                            labelText: 'Email de contacto',
                            hintText: 'Email para comunicaciones oficiales',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator:
                              (v) =>
                                  v == null || v.trim().isEmpty
                                      ? 'Campo obligatorio'
                                      : null,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Card de recursos
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
                        Row(
                          children: [
                            Icon(
                              Icons.event_available,
                              color: colorScheme.secondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Recursos reservables',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer.withOpacity(
                              0.3,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Define los espacios que los vecinos podrán reservar: pistas deportivas, salón de fiestas, barbacoas, etc.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Campo para agregar recurso
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _resourceCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Agregar recurso',
                                  hintText: 'Ej: Pista de pádel',
                                  prefixIcon: const Icon(
                                    Icons.add_box_outlined,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onFieldSubmitted: (_) => _addResource(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: colorScheme.secondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: _addResource,
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                tooltip: 'Agregar recurso',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Lista de recursos agregados
                        if (_resources.isNotEmpty) ...[
                          Text(
                            'Recursos configurados (${_resources.length})',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(_resources.length, (index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: colorScheme.secondary.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.event_available,
                                    color: colorScheme.secondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _resources[index],
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _removeResource(index),
                                    tooltip: 'Eliminar recurso',
                                  ),
                                ],
                              ),
                            );
                          }),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Aún no has agregado recursos. Puedes hacerlo más tarde desde la configuración.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface.withOpacity(
                                        0.6,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Error message
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
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

                // Botón de crear
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
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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
                              Icons.rocket_launch,
                              color: Colors.white,
                            ),
                    label: Text(
                      _loading
                          ? 'Creando comunidad...'
                          : 'Finalizar configuración',
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
      ),
    );
  }
}
