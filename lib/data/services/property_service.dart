import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecigest/domain/models/property_model.dart';

class PropertyService {
  final FirebaseFirestore _firestore;
  PropertyService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _viviendasRef(String communityId) {
    return _firestore
        .collection('communities')
        .doc(communityId)
        .collection('viviendas');
  }

  // Obtener todas las viviendas de una comunidad
  Stream<List<PropertyModel>> getProperties({required String communityId}) {
    return _viviendasRef(communityId)
        .orderBy('number')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => PropertyModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // Obtener una vivienda por su ID
  Future<PropertyModel?> getPropertyById(
    String communityId,
    String viviendaId,
  ) async {
    final doc = await _viviendasRef(communityId).doc(viviendaId).get();
    if (!doc.exists) return null;
    return PropertyModel.fromFirestore(doc);
  }

  // Crear una nueva vivienda
  Future<PropertyModel> createProperty({
    required String communityId,
    required String number,
    required String floor,
    required String block,
    required int size,
    required String ownerId,
    String? userId,
    Map<String, dynamic>? additionalInfo,
  }) async {
    final propertyData = {
      'number': number,
      'floor': floor,
      'block': block,
      'size': size,
      'ownerId': ownerId,
      'userId': userId,
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'additionalInfo': additionalInfo,
    };
    final docRef = await _viviendasRef(communityId).add(propertyData);
    final newDoc = await docRef.get();
    return PropertyModel.fromFirestore(newDoc);
  }

  // Actualizar una vivienda existente
  Future<void> updateProperty(
    String communityId,
    String viviendaId,
    Map<String, dynamic> data,
  ) async {
    await _viviendasRef(communityId).doc(viviendaId).update(data);
  }

  // Eliminar una vivienda
  Future<void> deleteProperty(String communityId, String viviendaId) async {
    await _viviendasRef(communityId).doc(viviendaId).delete();
  }

  // Verifica si un usuario ya está asignado a una vivienda en la comunidad
  Future<bool> isUserAssignedToAnyProperty(
    String communityId,
    String userId,
  ) async {
    final query =
        await _viviendasRef(
          communityId,
        ).where('userId', isEqualTo: userId).get();
    return query.docs.isNotEmpty;
  }

  // Verifica si una vivienda ya tiene usuario asignado
  Future<bool> isPropertyAssigned(String communityId, String viviendaId) async {
    final doc = await _viviendasRef(communityId).doc(viviendaId).get();
    return doc.exists && doc['userId'] != null;
  }

  // Asignar un usuario a una vivienda, evitando asignaciones dobles
  Future<void> assignUserToProperty(
    String communityId,
    String viviendaId,
    String userId,
  ) async {
    if (await isUserAssignedToAnyProperty(communityId, userId)) {
      throw Exception('Este usuario ya está asignado a una vivienda.');
    }
    if (await isPropertyAssigned(communityId, viviendaId)) {
      throw Exception('Esta vivienda ya tiene un usuario asignado.');
    }
    await _viviendasRef(communityId).doc(viviendaId).update({'userId': userId});
  }

  // Desasignar un usuario de una vivienda
  Future<void> unassignUserFromProperty(
    String communityId,
    String viviendaId,
  ) async {
    await _viviendasRef(communityId).doc(viviendaId).update({'userId': null});
  }

  // Obtener viviendas por usuario asignado
  Stream<List<PropertyModel>> getPropertiesByUser({
    required String communityId,
    required String userId,
  }) {
    return _viviendasRef(communityId)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => PropertyModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // Obtener viviendas sin usuario asignado
  Stream<List<PropertyModel>> getUnassignedProperties({
    required String communityId,
  }) {
    return _viviendasRef(communityId)
        .where('userId', isNull: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => PropertyModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // Obtener viviendas de un usuario específico (versión Future)
  Future<List<PropertyModel>> getUserProperties(
    String communityId,
    String userId,
  ) async {
    final snapshot =
        await _viviendasRef(
          communityId,
        ).where('userId', isEqualTo: userId).get();

    return snapshot.docs
        .map((doc) => PropertyModel.fromFirestore(doc))
        .toList();
  }
}
