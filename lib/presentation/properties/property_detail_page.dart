import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecigest/domain/models/property_model.dart';
import 'package:vecigest/data/services/property_service.dart';
import 'package:vecigest/data/services/invite_service.dart';
import 'package:vecigest/presentation/properties/token_management_page.dart';

class PropertyDetailPage extends StatefulWidget {
  final String communityId;
  final PropertyModel? property;

  const PropertyDetailPage({
    super.key,
    required this.communityId,
    this.property,
  });

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final PropertyService _propertyService = PropertyService();
  final InviteService _inviteService = InviteService();

  // Animation controllers
  late AnimationController _animationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _buttonScaleAnimation;

  // Form controllers
  final _numberController = TextEditingController();
  final _pisoController = TextEditingController();
  final _portalController = TextEditingController();
  final _informacionComplementariaController = TextEditingController();

  // State
  bool _isLoading = false;
  bool _isEditMode = false;
  String? _assignedUserEmail;
  String? _inviteToken;
  bool _showTokenCard = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeForm();
    _loadUserData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  void _initializeForm() {
    _isEditMode = widget.property != null;

    if (_isEditMode) {
      final property = widget.property!;
      _numberController.text = property.number;
      _pisoController.text = property.piso;
      _portalController.text = property.portal;
      _informacionComplementariaController.text =
          property.informacionComplementaria ?? '';
    }
  }

  Future<void> _loadUserData() async {
    if (_isEditMode && widget.property?.userId != null) {
      try {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(widget.property!.userId!)
                .get();

        if (userDoc.exists) {
          setState(() {
            _assignedUserEmail = userDoc.data()?['email'] as String?;
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _buttonAnimationController.dispose();
    _numberController.dispose();
    _pisoController.dispose();
    _portalController.dispose();
    _informacionComplementariaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = Color(0xFF6366F1);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        toolbarHeight: 98, // Increased by 75% from standard 56px
        title: Text(
          _isEditMode ? 'Editar Vivienda' : 'Nueva Vivienda',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: primaryColor.withOpacity(0.3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                primaryColor.withOpacity(0.9),
                const Color(0xFF4F46E5),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: _buildContent(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header icon
            _buildHeaderIcon(),
            const SizedBox(height: 32),

            // Form fields
            _buildFormFields(),
            const SizedBox(height: 32),

            // Assignment section (edit mode only)
            if (_isEditMode) ...[
              _buildAssignmentSection(),
              const SizedBox(height: 32),
            ],

            // Token management section (edit mode only)
            if (_isEditMode) ...[
              _buildTokenSection(),
              const SizedBox(height: 32),
            ],

            // Action buttons
            _buildActionButtons(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(Icons.home, size: 40, color: Colors.white),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Number field
        _buildAnimatedTextField(
          controller: _numberController,
          label: 'Número de Vivienda',
          hint: 'Ej: 1A, 2B, 101',
          icon: Icons.numbers,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'El número es obligatorio';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Floor and Portal in row
        Row(
          children: [
            Expanded(
              child: _buildAnimatedTextField(
                controller: _pisoController,
                label: 'Piso',
                hint: 'Ej: 1, 2, 3',
                icon: Icons.stairs,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAnimatedTextField(
                controller: _portalController,
                label: 'Portal',
                hint: 'Ej: A, B, C',
                icon: Icons.domain,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Additional info
        _buildAnimatedTextField(
          controller: _informacionComplementariaController,
          label: 'Información Complementaria',
          hint: 'Información adicional (opcional)',
          icon: Icons.info_outline,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: controller,
                  validator: validator,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    labelText: label,
                    hintText: hint,
                    prefixIcon: Icon(icon),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssignmentSection() {
    final hasUser = widget.property?.userId != null;

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
                Icon(
                  hasUser ? Icons.person : Icons.person_off,
                  color: hasUser ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 12),
                Text(
                  'Estado de Asignación',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (hasUser) ...[
              _buildInfoRow(
                icon: Icons.email,
                label: 'Usuario asignado',
                value: _assignedUserEmail ?? widget.property!.userId!,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _showUnassignDialog,
                icon: const Icon(Icons.person_remove),
                label: const Text('Desasignar Usuario'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ] else ...[
              Text(
                'Esta vivienda no tiene usuario asignado',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _generateInviteToken(),
                icon: const Icon(Icons.person_add),
                label: const Text('Generar Invitación'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTokenSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.vpn_key, color: Color(0xFF6366F1)),
                  const SizedBox(width: 12),
                  Text(
                    'Token de Invitación',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_showTokenCard && _inviteToken != null) ...[
                _buildTokenCard(),
              ] else ...[
                Text(
                  'Genera un token para invitar usuarios a esta vivienda',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _generateInviteToken,
                        icon: const Icon(Icons.add_link),
                        label: const Text('Generar Token'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _navigateToTokenManagement,
                      icon: const Icon(Icons.manage_accounts),
                      label: const Text('Gestionar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTokenCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security, color: Colors.white),
              const SizedBox(width: 8),
              const Text(
                'Token de Invitación',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ACTIVO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _inviteToken!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _copyTokenToClipboard,
                  icon: const Icon(Icons.copy, color: Colors.white),
                  tooltip: 'Copiar token',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                'Expira en 7 días',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _generateInviteToken,
                child: const Text(
                  'Regenerar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
        Expanded(child: Text(value, style: TextStyle(color: Colors.grey[600]))),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Save button
        AnimatedBuilder(
          animation: _buttonScaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _buttonScaleAnimation.value,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProperty,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                          : Icon(_isEditMode ? Icons.save : Icons.add),
                  label: Text(
                    _isLoading
                        ? 'Guardando...'
                        : (_isEditMode ? 'Guardar Cambios' : 'Crear Vivienda'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Delete button (edit mode only)
        if (_isEditMode) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _showDeleteDialog,
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text(
              'Eliminar Vivienda',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _saveProperty() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final number = _numberController.text.trim();
      final piso = _pisoController.text.trim();
      final portal = _portalController.text.trim();
      final informacionComplementaria =
          _informacionComplementariaController.text.trim();

      if (_isEditMode) {
        // Update existing property
        await _propertyService
            .updateProperty(widget.communityId, widget.property!.viviendaId, {
              'number': number,
              'piso': piso,
              'portal': portal,
              'informacionComplementaria':
                  informacionComplementaria.isEmpty
                      ? null
                      : informacionComplementaria,
            });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vivienda actualizada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Create new property
        await _propertyService.createProperty(
          communityId: widget.communityId,
          number: number,
          piso: piso,
          portal: portal,
          size: 0,
          ownerId: user.uid,
          informacionComplementaria:
              informacionComplementaria.isEmpty
                  ? null
                  : informacionComplementaria,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vivienda creada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _generateInviteToken() async {
    if (!_isEditMode) return;

    try {
      setState(() => _isLoading = true);

      final invite = await _inviteService.createInvite(
        communityId: widget.communityId,
        role: 'resident',
        viviendaId: widget.property!.viviendaId,
      );

      setState(() {
        _inviteToken = invite.token;
        _showTokenCard = true;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token de invitación generado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar token: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyTokenToClipboard() async {
    if (_inviteToken != null) {
      await Clipboard.setData(ClipboardData(text: _inviteToken!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token copiado al portapapeles'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _navigateToTokenManagement() {
    if (!_isEditMode) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TokenManagementPage(
              communityId: widget.communityId,
              property: widget.property!,
            ),
      ),
    );
  }

  void _showUnassignDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Desasignar Usuario'),
            content: const Text(
              '¿Estás seguro de que quieres desasignar al usuario de esta vivienda?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _unassignUser();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Desasignar'),
              ),
            ],
          ),
    );
  }

  Future<void> _unassignUser() async {
    try {
      await _propertyService.updateProperty(
        widget.communityId,
        widget.property!.viviendaId,
        {'userId': FieldValue.delete()},
      );

      setState(() {
        _assignedUserEmail = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario desasignado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al desasignar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar Vivienda'),
            content: Text(
              '¿Estás seguro de que quieres eliminar la vivienda ${widget.property?.fullIdentifier}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _deleteProperty();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteProperty() async {
    try {
      await _propertyService.deleteProperty(
        widget.communityId,
        widget.property!.viviendaId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vivienda eliminada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
