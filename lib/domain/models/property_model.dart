import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PropertyModel extends Equatable {
  final String viviendaId; // id de la vivienda (id del documento)
  final String communityId; // id de la comunidad
  final String
  number; // Número/identificador de la vivienda (ej: "2B", "101", etc.)
  final String piso; // Piso/Planta
  final String portal; // Portal/Entrada del edificio
  final int size; // Tamaño en metros cuadrados
  final String ownerId; // ID del propietario
  final String?
  userId; // ID del usuario asignado (puede ser diferente del propietario si alquila)
  final DateTime createdAt;
  final String?
  informacionComplementaria; // Información adicional/complementaria

  const PropertyModel({
    required this.viviendaId,
    required this.communityId,
    required this.number,
    required this.piso,
    required this.portal,
    required this.size,
    required this.ownerId,
    this.userId,
    required this.createdAt,
    this.informacionComplementaria,
  });

  factory PropertyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Intentar inferir communityId desde la ruta padre si no está presente en los datos
    String? communityId = data['communityId'];
    if (communityId == null && doc.reference.parent.parent != null) {
      communityId = doc.reference.parent.parent!.id;
    }
    return PropertyModel(
      viviendaId: doc.id,
      communityId: communityId ?? '',
      number: data['number'] ?? '',
      piso:
          data['piso'] ??
          data['floor'] ??
          '', // Support both old and new field names
      portal:
          data['portal'] ??
          data['block'] ??
          '', // Support both old and new field names
      size: data['size'] ?? 0,
      ownerId: data['ownerId'] ?? '',
      userId: data['userId'],
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      informacionComplementaria:
          data['informacionComplementaria'] ??
          (data['additionalInfo'] != null &&
                  data['additionalInfo']['notes'] != null
              ? data['additionalInfo']['notes'] as String
              : null),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'communityId': communityId,
      'number': number,
      'piso': piso,
      'portal': portal,
      'size': size,
      'ownerId': ownerId,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'informacionComplementaria': informacionComplementaria,
    };
  }

  String get fullIdentifier {
    // Crea un identificador completo de la vivienda
    if (portal.isNotEmpty) {
      return "$portal-$piso-$number";
    }
    return "$piso-$number";
  }

  PropertyModel copyWith({
    String? number,
    String? piso,
    String? portal,
    int? size,
    String? ownerId,
    String? userId,
    String? informacionComplementaria,
  }) {
    return PropertyModel(
      viviendaId: viviendaId,
      communityId: communityId,
      number: number ?? this.number,
      piso: piso ?? this.piso,
      portal: portal ?? this.portal,
      size: size ?? this.size,
      ownerId: ownerId ?? this.ownerId,
      userId: userId ?? this.userId,
      createdAt: createdAt,
      informacionComplementaria:
          informacionComplementaria ?? this.informacionComplementaria,
    );
  }

  @override
  List<Object?> get props => [
    viviendaId,
    communityId,
    number,
    piso,
    portal,
    size,
    ownerId,
    userId,
    createdAt,
    informacionComplementaria,
  ];
}
