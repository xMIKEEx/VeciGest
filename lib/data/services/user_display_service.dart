import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecigest/data/services/property_service.dart';
import 'package:vecigest/domain/models/property_model.dart';

class UserDisplayService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PropertyService _propertyService = PropertyService();

  /// Get user display info with property details
  Future<Map<String, dynamic>?> getUserDisplayInfo(String userId) async {
    try {
      // Get user document
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return null;
      }

      final userData = userDoc.data()!;
      final communityId = userData['communityId'] as String?;
      final viviendaId = userData['viviendaId'] as String?;
      final userName =
          userData['name']
              as String?; // If we have property info, get the detailed property data
      if (communityId != null && viviendaId != null) {
        try {
          final property = await _propertyService.getPropertyById(
            communityId,
            viviendaId,
          );

          if (property != null) {
            return {
              'name': userName ?? 'Usuario',
              'property': property,
              'propertyDisplay': _formatPropertyDisplay(property),
              'fullDisplay': _formatFullDisplay(userName, property),
              'userId': userId,
            };
          } else {
            // Property not found, return basic info
            return {
              'name': userName ?? 'Usuario',
              'propertyDisplay': viviendaId,
              'fullDisplay': userName ?? 'Usuario',
              'userId': userId,
            };
          }
        } catch (e) {
          // If property fetch fails, return basic info
          return {
            'name': userName ?? 'Usuario',
            'propertyDisplay': viviendaId,
            'fullDisplay': userName ?? 'Usuario',
            'userId': userId,
          };
        }
      }

      // Return basic user info if no property data
      return {
        'name': userName ?? 'Usuario',
        'propertyDisplay': 'Sin vivienda asignada',
        'fullDisplay': userName ?? 'Usuario',
        'userId': userId,
      };
    } catch (e) {
      print('Error getting user display info: $e');
      return null;
    }
  }

  /// Format property display as "Number • Pisoº • Portal X"
  String _formatPropertyDisplay(PropertyModel property) {
    final parts = <String>[];

    if (property.number.isNotEmpty) {
      parts.add(property.number);
    }

    if (property.piso.isNotEmpty) {
      parts.add('${property.piso}º');
    }

    if (property.portal.isNotEmpty) {
      parts.add('Portal ${property.portal}');
    }

    return parts.isNotEmpty ? parts.join(' • ') : 'Vivienda';
  }

  /// Format full display as "Name (Property)"
  String _formatFullDisplay(String? name, PropertyModel property) {
    final userName = name ?? 'Usuario';
    final propertyDisplay = _formatPropertyDisplay(property);
    return '$userName ($propertyDisplay)';
  }

  /// Get multiple users display info (for batch operations)
  Future<Map<String, Map<String, dynamic>>> getBatchUserDisplayInfo(
    List<String> userIds,
  ) async {
    final results = <String, Map<String, dynamic>>{};

    for (final userId in userIds) {
      final userInfo = await getUserDisplayInfo(userId);
      if (userInfo != null) {
        results[userId] = userInfo;
      }
    }

    return results;
  }
}
