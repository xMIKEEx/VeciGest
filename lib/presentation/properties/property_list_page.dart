import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vecigest/domain/models/property_model.dart';
import 'package:vecigest/data/services/property_service.dart';
import 'package:vecigest/data/services/user_role_service.dart';
import 'package:vecigest/presentation/properties/property_detail_page.dart';
import 'package:vecigest/presentation/properties/invitations_list_page.dart';

class PropertyListPage extends StatefulWidget {
  final Function(Widget)? onNavigate;

  const PropertyListPage({super.key, this.onNavigate});

  @override
  State<PropertyListPage> createState() => _PropertyListPageState();
}

class _PropertyListPageState extends State<PropertyListPage>
    with TickerProviderStateMixin {
  final PropertyService _propertyService = PropertyService();
  final UserRoleService _userRoleService = UserRoleService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  String? _communityId;
  bool _isAdmin = false;
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  Future<void> _loadData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = 'Usuario no autenticado';
          _isInitialized = true;
        });
        return;
      }

      final userRole = await _userRoleService.getUserRoleAndCommunity(user.uid);

      if (userRole == null || userRole['communityId'] == null) {
        setState(() {
          _error = 'No se pudo obtener la información de la comunidad';
          _isInitialized = true;
        });
        return;
      }

      setState(() {
        _communityId = userRole['communityId'];
        _isAdmin = userRole['role'] == 'admin';
        _isInitialized = true;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar datos: $e';
        _isInitialized = true;
      });
    }
  }

  void _navigateToPropertyDetail({PropertyModel? property}) {
    if (_communityId == null) return;

    final page = PropertyDetailPage(
      communityId: _communityId!,
      property: property,
    );

    if (widget.onNavigate != null) {
      widget.onNavigate!(page);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    }
  }

  void _navigateToInvitations() {
    final page = const InvitationsListPage();

    if (widget.onNavigate != null) {
      widget.onNavigate!(page);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Main content with padding for floating header
          Padding(
            padding: const EdgeInsets.only(
              top: 220,
            ), // Increased from 200 to 220
            child: _buildContent(),
          ),
          // Floating header
          _buildFloatingHeader(),
        ],
      ),
    );
  }

  Widget _buildFloatingHeader() {
    const primaryColor = Color(0xFF6366F1); // Indigo theme

    return Positioned(
      top: 20,
      left: 16,
      right: 16,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Card(
                  elevation: 8,
                  shadowColor: primaryColor.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    height: 160, // Increased from 140 to accommodate content
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor,
                          primaryColor.withValues(alpha: 0.9),
                          const Color(0xFF4F46E5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        // Decorative elements
                        Positioned(
                          top: -10,
                          right: -20,
                          child: Icon(
                            Icons.home_work,
                            size: 100,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(
                            20,
                          ), // Reduced from 24 to 20
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize:
                                MainAxisSize.min, // Added to prevent overflow
                            children: [
                              const Text(
                                'Viviendas',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 28,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Gestiona las propiedades de la comunidad',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              // Action buttons
                              Row(
                                children: [
                                  _buildHeaderButton(
                                    icon: Icons.arrow_back,
                                    label: 'Salir',
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  const SizedBox(width: 12),
                                  if (_isAdmin) ...[
                                    _buildHeaderButton(
                                      icon: Icons.add,
                                      label: 'Añadir',
                                      onPressed:
                                          () => _navigateToPropertyDetail(),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  _buildHeaderButton(
                                    icon: Icons.mail_outline,
                                    label: 'Invitaciones',
                                    onPressed: _navigateToInvitations,
                                  ),
                                ],
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
          },
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF6366F1),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
      ),
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildContent() {
    if (!_isInitialized) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_communityId == null) {
      return _buildErrorState();
    }
    return StreamBuilder<List<PropertyModel>>(
      stream: _propertyService.getProperties(communityId: _communityId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(error: snapshot.error.toString());
        }

        final properties = snapshot.data ?? [];

        if (properties.isEmpty) {
          return _buildEmptyState();
        }

        return _buildPropertiesList(properties);
      },
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 120,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState({String? error}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              error ?? _error ?? 'Error desconocido',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isInitialized = false;
                  _error = null;
                });
                _loadData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_work_outlined,
              size: 80,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay viviendas registradas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _isAdmin
                  ? 'Añade la primera vivienda para comenzar'
                  : 'Contacta con el administrador para registrar viviendas',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (_isAdmin) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _navigateToPropertyDetail(),
                icon: const Icon(Icons.add),
                label: const Text('Añadir vivienda'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPropertiesList(List<PropertyModel> properties) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: properties.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value * (1 - index * 0.1)),
                  child: _buildPropertyCard(properties[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPropertyCard(PropertyModel property) {
    final theme = Theme.of(context);
    final hasUser = property.userId != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToPropertyDetail(property: property),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.home,
                        color: theme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.fullIdentifier,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildStatusBadge(hasUser),
                        ],
                      ),
                    ),
                    if (_isAdmin)
                      PopupMenuButton<String>(
                        onSelected:
                            (value) => _handleMenuAction(value, property),
                        itemBuilder:
                            (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 16),
                                    SizedBox(width: 8),
                                    Text('Editar'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Eliminar',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Property details
                if (property.piso.isNotEmpty || property.portal.isNotEmpty) ...[
                  _buildDetailRow(Icons.stairs, 'Piso: ${property.piso}'),
                  _buildDetailRow(Icons.domain, 'Portal: ${property.portal}'),
                ],
                if (property.informacionComplementaria?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.info_outline,
                    property.informacionComplementaria!,
                  ),
                ],
                if (hasUser) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.person,
                    'Asignado a: ${property.userId}',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool hasUser) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            hasUser
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasUser ? Icons.check_circle : Icons.pending,
            size: 14,
            color: hasUser ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            hasUser ? 'Ocupada' : 'Disponible',
            style: TextStyle(
              color: hasUser ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, PropertyModel property) {
    switch (action) {
      case 'edit':
        _navigateToPropertyDetail(property: property);
        break;
      case 'delete':
        _showDeleteConfirmation(property);
        break;
    }
  }

  void _showDeleteConfirmation(PropertyModel property) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar vivienda'),
            content: Text(
              '¿Estás seguro de que quieres eliminar la vivienda ${property.fullIdentifier}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _deleteProperty(property);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteProperty(PropertyModel property) async {
    try {
      await _propertyService.deleteProperty(_communityId!, property.viviendaId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vivienda ${property.fullIdentifier} eliminada'),
            backgroundColor: Colors.green,
          ),
        );
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
