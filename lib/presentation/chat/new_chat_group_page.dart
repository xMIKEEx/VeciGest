import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vecigest/data/services/chat_service.dart';
import 'package:vecigest/data/services/property_service.dart';
import 'package:vecigest/data/services/user_role_service.dart';
import 'package:vecigest/domain/models/property_model.dart';
import 'package:vecigest/domain/models/user_model.dart';

class NewChatGroupPage extends StatefulWidget {
  const NewChatGroupPage({super.key});

  @override
  State<NewChatGroupPage> createState() => _NewChatGroupPageState();
}

class _NewChatGroupPageState extends State<NewChatGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ChatService _chatService = ChatService();
  final PropertyService _propertyService = PropertyService();
  final UserRoleService _userRoleService = UserRoleService();

  List<PropertyModel> _availableProperties = [];
  final List<String> _selectedPropertyIds = [];
  bool _isLoading = false;
  bool _isLoadingProperties = true;
  String? _error;
  String? _communityId;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndProperties();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDataAndProperties() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final userRole = await _userRoleService.getUserRoleAndCommunity(user.uid);
      if (userRole == null || userRole['role'] != 'admin') {
        throw Exception('Solo los administradores pueden crear grupos de chat');
      }

      _communityId = userRole['communityId'];
      if (_communityId == null) {
        throw Exception('No se encontró la comunidad del usuario');
      }

      final properties =
          await _propertyService
              .getProperties(communityId: _communityId!)
              .first;

      setState(() {
        _availableProperties = properties;
        _isLoadingProperties = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingProperties = false;
      });
    }
  }

  Future<void> _createChatGroup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPropertyIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos una vivienda para el chat grupal'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final userModel = UserModel.fromFirebaseUser(user);

      await _chatService.createThread(
        _titleController.text.trim(),
        userModel,
        _selectedPropertyIds,
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
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

  void _togglePropertySelection(String propertyId) {
    setState(() {
      if (_selectedPropertyIds.contains(propertyId)) {
        _selectedPropertyIds.remove(propertyId);
      } else {
        _selectedPropertyIds.add(propertyId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Main content with padding for floating header
          Padding(
            padding: const EdgeInsets.only(
              top: 220,
              bottom: 16,
              left: 16,
              right: 16,
            ),
            child:
                _isLoadingProperties
                    ? const Center(child: CircularProgressIndicator())
                    : _buildForm(theme),
          ),
          // Floating header
          _buildFloatingHeader(),
        ],
      ),
    );
  }

  Widget _buildFloatingHeader() {
    const orangeColor = Color(0xFFFF6B35);

    return Positioned(
      top: 0,
      left: 16,
      right: 16,
      child: SafeArea(
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  orangeColor,
                  orangeColor.withOpacity(0.9),
                  const Color(0xFFE85A2B),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              children: [
                // Elemento decorativo
                Positioned(
                  top: 10,
                  right: -20,
                  child: Icon(
                    Icons.group_add,
                    size: 80,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                // Back button
                Positioned(
                  top: 16,
                  left: 16,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                // Contenido principal
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Grupo superior: título y subtítulo
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Título principal
                            const Text(
                              'Nuevo Chat Grupal',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 26,
                              ),
                            ),
                            // Subtítulo
                            Text(
                              'Crea un chat grupal para viviendas específicas',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoCard(theme),
            const SizedBox(height: 20),
            _buildPropertySelectionCard(theme),
            const SizedBox(height: 24),
            if (_error != null) _buildErrorCard(theme),
            _buildCreateButton(theme),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(ThemeData theme) {
    const orangeColor = Color(0xFFFF6B35);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: orangeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.edit, color: orangeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Información del Chat',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Nombre del Chat *',
                hintText: 'Ej: Chat Bloque A, Administración, etc.',
                prefixIcon: Icon(Icons.title, color: orangeColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: orangeColor, width: 2),
                ),
                labelStyle: TextStyle(color: orangeColor),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre del chat es obligatorio';
                }
                if (value.length < 3) {
                  return 'El nombre debe tener al menos 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Describe el propósito de este chat grupal',
                prefixIcon: Icon(Icons.description, color: orangeColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: orangeColor, width: 2),
                ),
                labelStyle: TextStyle(color: orangeColor),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertySelectionCard(ThemeData theme) {
    const orangeColor = Color(0xFFFF6B35);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: orangeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.home, color: orangeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Viviendas Autorizadas',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Selecciona las viviendas que tendrán acceso',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _selectedPropertyIds.isEmpty
                            ? orangeColor.withOpacity(0.7)
                            : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedPropertyIds.length} seleccionadas',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_availableProperties.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No hay viviendas disponibles en tu comunidad',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._availableProperties.map(
                (property) => _buildPropertyTile(property, theme),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyTile(PropertyModel property, ThemeData theme) {
    final isSelected = _selectedPropertyIds.contains(property.viviendaId);

    return CheckboxListTile(
      value: isSelected,
      onChanged: (_) => _togglePropertySelection(property.viviendaId),
      title: Text(
        'Vivienda ${property.viviendaId}',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFFFF6B35).withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.apartment,
          color: isSelected ? const Color(0xFFFF6B35) : Colors.grey,
          size: 20,
        ),
      ),
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }

  Widget _buildErrorCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(ThemeData theme) {
    const orangeColor = Color(0xFFFF6B35);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _createChatGroup,
        style: ElevatedButton.styleFrom(
          backgroundColor: orangeColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        icon:
            _isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : const Icon(Icons.group_add, size: 20),
        label: Text(
          _isLoading ? 'Creando...' : 'Crear Chat Grupal',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
