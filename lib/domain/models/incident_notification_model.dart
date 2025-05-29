class IncidentNotification {
  final String id;
  final String incidentId;
  final String incidentTitle;
  final String
  type; // 'created', 'status_changed', 'completed', 'updated', 'deleted'
  final String message;
  final String? oldValue;
  final String? newValue;
  final DateTime timestamp;
  final String userId;
  final String userEmail;
  final String communityId; // Nuevo campo para filtrar por comunidad
  final List<String>
  hiddenByUsers; // Lista de usuarios que han ocultado esta notificación

  IncidentNotification({
    required this.id,
    required this.incidentId,
    required this.incidentTitle,
    required this.type,
    required this.message,
    this.oldValue,
    this.newValue,
    required this.timestamp,
    required this.userId,
    required this.userEmail,
    required this.communityId,
    this.hiddenByUsers = const [],
  });
  factory IncidentNotification.fromMap(Map<String, dynamic> map) {
    // Soporta Timestamp de Firestore y String ISO
    DateTime parsedTimestamp;
    final ts = map['timestamp'];
    if (ts is String) {
      parsedTimestamp = DateTime.parse(ts);
    } else if (ts is DateTime) {
      parsedTimestamp = ts;
    } else if (ts != null && ts.toString().contains('Timestamp')) {
      // Firestore Timestamp
      parsedTimestamp = (ts as dynamic).toDate();
    } else {
      parsedTimestamp = DateTime.now();
    }
    return IncidentNotification(
      id: map['id'] ?? '',
      incidentId: map['incidentId'] ?? '',
      incidentTitle: map['incidentTitle'] ?? '',
      type: map['type'] ?? '',
      message: map['message'] ?? '',
      oldValue: map['oldValue'],
      newValue: map['newValue'],
      timestamp: parsedTimestamp,
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      communityId: map['communityId'] ?? '',
      hiddenByUsers: List<String>.from(map['hiddenByUsers'] ?? []),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'incidentId': incidentId,
      'incidentTitle': incidentTitle,
      'type': type,
      'message': message,
      'oldValue': oldValue,
      'newValue': newValue,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'userEmail': userEmail,
      'communityId': communityId,
      'hiddenByUsers': hiddenByUsers,
    };
  }

  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  String get typeDisplay {
    switch (type) {
      case 'created':
        return 'Creada';
      case 'status_changed':
        return 'Estado cambiado';
      case 'completed':
        return 'Completada';
      case 'updated':
        return 'Actualizada';
      case 'deleted':
        return 'Eliminada';
      default:
        return 'Cambio';
    }
  }
}
