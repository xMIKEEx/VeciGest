import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vecigest/data/services/property_service.dart';
import 'package:vecigest/domain/models/property_model.dart';
import 'user_avatar.dart';

class ContextInfoCard extends StatefulWidget {
  final Map<String, dynamic>? userRole;
  final bool isAdmin;
  const ContextInfoCard({
    super.key,
    required this.userRole,
    required this.isAdmin,
  });

  @override
  State<ContextInfoCard> createState() => _ContextInfoCardState();
}

class _ContextInfoCardState extends State<ContextInfoCard> {
  final PropertyService _propertyService = PropertyService();
  PropertyModel? _propertyDetails;

  @override
  void initState() {
    super.initState();
    _loadPropertyDetails();
  }

  @override
  void didUpdateWidget(ContextInfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userRole != widget.userRole) {
      _loadPropertyDetails();
    }
  }

  Future<void> _loadPropertyDetails() async {
    final viviendaId = widget.userRole?['viviendaId'] as String?;
    final communityId = widget.userRole?['communityId'] as String?;
    
    if (viviendaId != null && viviendaId.isNotEmpty && 
        communityId != null && communityId.isNotEmpty) {
      try {
        final property = await _propertyService.getPropertyById(
          communityId,
          viviendaId,
        );
        if (mounted) {
          setState(() {
            _propertyDetails = property;
          });
        }
      } catch (e) {
        print('Error loading property details: $e');
      }
    }
  }

  String _getHousingDisplay() {
    if (_propertyDetails != null) {
      final parts = <String>[];
      
      if (_propertyDetails!.number.isNotEmpty) {
        parts.add(_propertyDetails!.number);
      }
      
      if (_propertyDetails!.piso.isNotEmpty) {
        parts.add('${_propertyDetails!.piso}º');
      }
      
      if (_propertyDetails!.portal.isNotEmpty) {
        parts.add('Portal ${_propertyDetails!.portal}');
      }
      
      return parts.isNotEmpty ? parts.join(' • ') : 'Mi Vivienda';
    }
    
    // Fallback a la información existente
    final viviendaId = widget.userRole?['viviendaId'] as String?;
    if (viviendaId != null && viviendaId.isNotEmpty) {
      return viviendaId;
    }
    return 'Mi Vivienda';
  }
  
  String _getCommunityDisplay() {
    final communityName = widget.userRole?['communityName'] as String?;
    if (communityName != null && communityName.isNotEmpty) {
      return communityName;
    }
    return 'Mi Comunidad';
  }

  String _getRoleDisplay() {
    final role = widget.userRole?['role'] as String?;
    if (role == 'admin') {
      return 'Administrador';
    } else if (role == 'user') {
      return 'Residente';
    }
    return 'Miembro';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            UserAvatar(user: user, userRole: widget.userRole),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Housing information (moved to top, more prominent)
                  Row(
                    children: [
                      Icon(
                        Icons.home_outlined,
                        size: 18,
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _getHousingDisplay(),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Community name
                  Row(
                    children: [
                      Icon(
                        Icons.apartment_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _getCommunityDisplay(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontFamily: 'Inter',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // User role
                  Row(
                    children: [
                      Icon(
                        widget.isAdmin
                            ? Icons.admin_panel_settings
                            : Icons.person_outline,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _getRoleDisplay(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontFamily: 'Inter',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (widget.isAdmin)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber[800]),
                    const SizedBox(width: 4),
                    Text(
                      'Admin',
                      style: TextStyle(
                        color: Colors.amber[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
