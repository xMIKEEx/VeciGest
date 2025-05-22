import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PropertyModel extends Equatable {
  final String viviendaId; // id de la vivienda (id del documento)
  final String communityId; // id de la comunidad
  final String
  number; // Número/identificador de la vivienda (ej: "2B", "101", etc.)
  final String floor; // Planta
  final String block; // Bloque o edificio si aplica
  final int size; // Tamaño en metros cuadrados
  final String ownerId; // ID del propietario
  final String?
  userId; // ID del usuario asignado (puede ser diferente del propietario si alquila)
  final DateTime createdAt;
  final Map<String, dynamic>?
  additionalInfo; // Información adicional (notas, características)
  const PropertyModel({
    required this.viviendaId,
    required this.communityId,
    required this.number,
    required this.floor,
    required this.block,
    required this.size,
    required this.ownerId,
    this.userId,
    required this.createdAt,
    this.additionalInfo,
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
      floor: data['floor'] ?? '',
      block: data['block'] ?? '',
      size: data['size'] ?? 0,
      ownerId: data['ownerId'] ?? '',
      userId: data['userId'],
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      additionalInfo: data['additionalInfo'] as Map<String, dynamic>?,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'communityId': communityId,
      'number': number,
      'floor': floor,
      'block': block,
      'size': size,
      'ownerId': ownerId,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'additionalInfo': additionalInfo,
    };
  }

  String get fullIdentifier {
    // Crea un identificador completo de la vivienda
    if (block.isNotEmpty) {
      return "$block-$floor-$number";
    }
    return "$floor-$number";
  }

  PropertyModel copyWith({
    String? number,
    String? floor,
    String? block,
    int? size,
    String? ownerId,
    String? userId,
    Map<String, dynamic>? additionalInfo,
  }) {
    return PropertyModel(
      viviendaId: viviendaId,
      communityId: communityId,
      number: number ?? this.number,
      floor: floor ?? this.floor,
      block: block ?? this.block,
      size: size ?? this.size,
      ownerId: ownerId ?? this.ownerId,
      userId: userId ?? this.userId,
      createdAt: createdAt,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  @override
  List<Object?> get props => [
    viviendaId,
    communityId,
    number,
    floor,
    block,
    size,
    ownerId,
    userId,
    createdAt,
    additionalInfo,
  ];
}
