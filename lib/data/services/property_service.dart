import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecigest/domain/models/property_model.dart';

class PropertyService {
  final FirebaseFirestore _firestore;
  final CollectionReference _propertiesRef;

  PropertyService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _propertiesRef = (firestore ?? FirebaseFirestore.instance).collection(
        'properties',
      );

  // Obtener todas las propiedades de una comunidad
  Stream<List<PropertyModel>> getProperties({required String communityId}) {
    return _propertiesRef
        .where('communityId', isEqualTo: communityId)
        .orderBy('block')
        .orderBy('floor')
        .orderBy('number')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => PropertyModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // Obtener una propiedad por su ID
  Future<PropertyModel?> getPropertyById(String propertyId) async {
    final doc = await _propertiesRef.doc(propertyId).get();
    if (!doc.exists) return null;
    return PropertyModel.fromFirestore(doc);
  }

  // Crear una nueva propiedad
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
      'communityId': communityId,
      'number': number,
      'floor': floor,
      'block': block,
      'size': size,
      'ownerId': ownerId,
      'userId': userId,
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'additionalInfo': additionalInfo,
    };

    final docRef = await _propertiesRef.add(propertyData);
    final newDoc = await docRef.get();
    return PropertyModel.fromFirestore(newDoc);
  }

  // Actualizar una propiedad existente
  Future<void> updateProperty(
    String propertyId,
    Map<String, dynamic> data,
  ) async {
    await _propertiesRef.doc(propertyId).update(data);
  }

  // Eliminar una propiedad
  Future<void> deleteProperty(String propertyId) async {
    await _propertiesRef.doc(propertyId).delete();
  }

  // Verifica si un usuario ya está asignado a una vivienda
  Future<bool> isUserAssignedToAnyProperty(String userId) async {
    final query = await _propertiesRef.where('userId', isEqualTo: userId).get();
    return query.docs.isNotEmpty;
  }

  // Verifica si una vivienda ya tiene usuario asignado
  Future<bool> isPropertyAssigned(String propertyId) async {
    final doc = await _propertiesRef.doc(propertyId).get();
    return doc.exists && doc['userId'] != null;
  }

  // Asignar un usuario a una propiedad, evitando asignaciones dobles
  Future<void> assignUserToProperty(String propertyId, String userId) async {
    // Validación: ¿el usuario ya tiene vivienda?
    if (await isUserAssignedToAnyProperty(userId)) {
      throw Exception('Este usuario ya está asignado a una vivienda.');
    }
    // Validación: ¿la vivienda ya tiene usuario?
    if (await isPropertyAssigned(propertyId)) {
      throw Exception('Esta vivienda ya tiene un usuario asignado.');
    }
    await _propertiesRef.doc(propertyId).update({'userId': userId});
  }

  // Desasignar un usuario de una propiedad
  Future<void> unassignUserFromProperty(String propertyId) async {
    await _propertiesRef.doc(propertyId).update({'userId': null});
  }

  // Obtener propiedades por usuario asignado
  Stream<List<PropertyModel>> getPropertiesByUser({required String userId}) {
    return _propertiesRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => PropertyModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // Obtener propiedades sin usuario asignado
  Stream<List<PropertyModel>> getUnassignedProperties({
    required String communityId,
  }) {
    return _propertiesRef
        .where('communityId', isEqualTo: communityId)
        .where('userId', isNull: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => PropertyModel.fromFirestore(doc))
                  .toList(),
        );
  }
}
