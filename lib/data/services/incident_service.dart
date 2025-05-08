import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecigest/domain/models/incident_model.dart';

class IncidentService {
  final FirebaseFirestore _firestore;
  final CollectionReference _incidentsRef;

  IncidentService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _incidentsRef = (firestore ?? FirebaseFirestore.instance).collection(
        'incidents',
      );

  // Stream de incidencias con filtros opcionales
  Stream<List<IncidentModel>> getIncidents({
    String? filterByUserId,
    String? status,
  }) {
    try {
      Query query = _incidentsRef;
      if (filterByUserId != null) {
        query = query.where('createdBy', isEqualTo: filterByUserId);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }
      query = query.orderBy('createdAt', descending: true);
      return query.snapshots().map(
        (snapshot) =>
            snapshot.docs
                .map(
                  (doc) => IncidentModel.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  ),
                )
                .toList(),
      );
    } catch (e) {
      throw Exception('Error al obtener incidencias: $e');
    }
  }

  // Crear una nueva incidencia
  Future<IncidentModel> createIncident(IncidentModel incident) async {
    try {
      final data = incident.toMap();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['status'] = 'open';
      final docRef = await _incidentsRef.add(data);
      final doc = await docRef.get();
      return IncidentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Error al crear la incidencia: $e');
    }
  }

  // Actualizar el estado de una incidencia
  Future<void> updateIncidentStatus(String incidentId, String newStatus) async {
    try {
      await _incidentsRef.doc(incidentId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al actualizar el estado de la incidencia: $e');
    }
  }

  // Actualizar las URLs de las fotos de una incidencia
  Future<void> updateIncidentPhotosUrls(
    String incidentId,
    List<String> photoUrls,
  ) async {
    try {
      await _incidentsRef.doc(incidentId).update({
        'photosUrls': photoUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al actualizar las URLs de las fotos: $e');
    }
  }

  // Eliminar una incidencia
  Future<void> deleteIncident(String incidentId) async {
    try {
      await _incidentsRef.doc(incidentId).delete();
    } catch (e) {
      throw Exception('Error al eliminar la incidencia: $e');
    }
  }
}
