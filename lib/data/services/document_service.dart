import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vecigest/domain/models/document_model.dart';

class DocumentService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final CollectionReference _documentsRef;

  DocumentService({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance,
      _documentsRef = (firestore ?? FirebaseFirestore.instance).collection(
        'documents',
      );

  // Stream de documentos con filtro opcional por carpeta
  Stream<List<DocumentModel>> getDocuments({String? folder}) {
    try {
      Query query = _documentsRef;
      if (folder != null) {
        query = query.where('folder', isEqualTo: folder);
      }
      query = query.orderBy('uploadedAt', descending: true);
      return query.snapshots().map(
        (snapshot) =>
            snapshot.docs
                .map(
                  (doc) => DocumentModel.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  ),
                )
                .toList(),
      );
    } catch (e) {
      throw Exception('Error al obtener documentos: $e');
    }
  }

  // Subir un documento y crear su metadata en Firestore
  Future<DocumentModel> uploadDocument(
    File file, {
    required String folder,
    required String uploaderId,
  }) async {
    try {
      final fileName =
          DateTime.now().millisecondsSinceEpoch.toString() +
          '_' +
          file.path.split('/').last;
      final storagePath = 'documents/$folder/$fileName';
      final ref = _storage.ref().child(storagePath);
      final uploadTask = await ref.putFile(file);
      final url = await ref.getDownloadURL();
      final docData = {
        'name': fileName,
        'url': url,
        'folder': folder,
        'uploaderId': uploaderId,
        'uploadedAt': FieldValue.serverTimestamp(),
        'storagePath': storagePath,
      };
      final docRef = await _documentsRef.add(docData);
      final doc = await docRef.get();
      return DocumentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Error al subir el documento: $e');
    }
  }

  // Subir una foto para una incidencia y devolver su URL
  static Future<String> uploadIncidentPhoto(
    String incidentId,
    File photoFile,
  ) async {
    try {
      final fileName =
          DateTime.now().millisecondsSinceEpoch.toString() +
          '_' +
          photoFile.path.split('/').last;
      final storagePath = 'incidents/$incidentId/$fileName';
      final ref = FirebaseStorage.instance.ref().child(storagePath);
      final uploadTask = await ref.putFile(photoFile);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      throw Exception('Error al subir la foto de la incidencia: $e');
    }
  }

  // Eliminar documento de Firestore y Storage
  Future<void> deleteDocument(String documentId, String storagePath) async {
    try {
      await _documentsRef.doc(documentId).delete();
      await _storage.ref().child(storagePath).delete();
    } catch (e) {
      throw Exception('Error al eliminar el documento: $e');
    }
  }
}
