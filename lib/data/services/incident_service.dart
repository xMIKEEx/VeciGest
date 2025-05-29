import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecigest/domain/models/incident_model.dart';
import 'package:vecigest/data/services/incident_notification_service.dart';

class IncidentService {
  final CollectionReference _incidentsRef;
  final IncidentNotificationService _notificationService;

  IncidentService({FirebaseFirestore? firestore})
    : _incidentsRef = (firestore ?? FirebaseFirestore.instance).collection(
        'incidents',
      ),
      _notificationService = IncidentNotificationService();

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

      final createdIncident = IncidentModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );

      // Registrar notificación de creación
      await _notificationService.createIncidentNotification(
        incidentId: doc.id,
        incidentTitle: incident.title,
        type: 'created',
        message: 'Nueva incidencia creada: ${incident.title}',
      );

      return createdIncident;
    } catch (e) {
      throw Exception('Error al crear la incidencia: $e');
    }
  }

  // Actualizar el estado de una incidencia
  Future<void> updateIncidentStatus(String incidentId, String newStatus) async {
    try {
      // Obtener el estado actual antes de actualizar
      final currentDoc = await _incidentsRef.doc(incidentId).get();
      final currentData = currentDoc.data() as Map<String, dynamic>?;
      final oldStatus = currentData?['status'] as String?;
      final incidentTitle = currentData?['title'] as String? ?? 'Incidencia';

      await _incidentsRef.doc(incidentId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Registrar notificación de cambio de estado
      String notificationType = 'status_changed';
      String message = 'Estado cambiado de "$oldStatus" a "$newStatus"';

      if (newStatus == 'closed' || newStatus == 'resolved') {
        notificationType = 'completed';
        message = 'Incidencia completada: $incidentTitle';
      }

      await _notificationService.createIncidentNotification(
        incidentId: incidentId,
        incidentTitle: incidentTitle,
        type: notificationType,
        message: message,
        oldValue: oldStatus,
        newValue: newStatus,
      );
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
      // Obtener datos de la incidencia antes de eliminarla
      final currentDoc = await _incidentsRef.doc(incidentId).get();
      final currentData = currentDoc.data() as Map<String, dynamic>?;
      final incidentTitle = currentData?['title'] as String? ?? 'Incidencia';

      // Eliminar la incidencia
      await _incidentsRef.doc(incidentId).delete();

      // Registrar notificación de eliminación
      await _notificationService.createIncidentNotification(
        incidentId: incidentId,
        incidentTitle: incidentTitle,
        type: 'deleted',
        message: 'Incidencia eliminada: $incidentTitle',
      );
    } catch (e) {
      throw Exception('Error al eliminar la incidencia: $e');
    }
  }

  // Actualizar campos arbitrarios de una incidencia
  Future<void> updateIncidentFields(
    String incidentId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Obtener datos actuales para la notificación
      final currentDoc = await _incidentsRef.doc(incidentId).get();
      final currentData = currentDoc.data() as Map<String, dynamic>?;
      final incidentTitle = currentData?['title'] as String? ?? 'Incidencia';

      await _incidentsRef.doc(incidentId).update(data);

      // Registrar notificación de actualización
      await _notificationService.createIncidentNotification(
        incidentId: incidentId,
        incidentTitle: incidentTitle,
        type: 'updated',
        message: 'Incidencia actualizada: $incidentTitle',
      );
    } catch (e) {
      throw Exception('Error al actualizar la incidencia: $e');
    }
  }
}
