import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecigest/domain/models/poll_model.dart';
import 'package:vecigest/domain/models/poll_option_model.dart';

class PollService {
  final FirebaseFirestore _firestore;
  final CollectionReference _pollsRef;

  PollService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _pollsRef = (firestore ?? FirebaseFirestore.instance).collection('polls');

  // Stream de encuestas
  Stream<List<PollModel>> getPolls() {
    try {
      return _pollsRef
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map(
                      (doc) => PollModel.fromMap(
                        doc.data() as Map<String, dynamic>,
                        doc.id,
                      ),
                    )
                    .toList(),
          );
    } catch (e) {
      throw Exception('Error al obtener encuestas: $e');
    }
  }

  // Crear una nueva encuesta
  Future<PollModel> createPoll(
    String question,
    List<String> options,
    String creatorId,
  ) async {
    try {
      final pollData = {
        'question': question,
        'createdBy': creatorId,
        'createdAt': FieldValue.serverTimestamp(),
      };
      final pollRef = await _pollsRef.add(pollData);
      final pollId = pollRef.id;
      // Añadir opciones como subcolección
      for (final opt in options) {
        await pollRef.collection('options').add({'text': opt, 'votes': 0});
      }
      // Obtener opciones creadas
      final optionsSnap = await pollRef.collection('options').get();
      final pollOptions =
          optionsSnap.docs
              .map(
                (doc) => PollOptionModel.fromMap(doc.data(), doc.id, pollId),
              ) // Added pollId
              .toList();
      final pollDoc = await pollRef.get();
      return PollModel.fromMap(
        pollDoc.data() as Map<String, dynamic>,
        pollId,
        options: pollOptions,
      );
    } catch (e) {
      throw Exception('Error al crear la encuesta: $e');
    }
  }

  // Stream de opciones de una encuesta
  Stream<List<PollOptionModel>> getOptions(String pollId) {
    try {
      return _pollsRef
          .doc(pollId)
          .collection('options')
          .orderBy(FieldPath.documentId)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map(
                      (doc) =>
                          PollOptionModel.fromMap(doc.data(), doc.id, pollId),
                    ) // Added pollId
                    .toList(),
          );
    } catch (e) {
      throw Exception('Error al obtener opciones: $e');
    }
  }

  // Saber si un usuario ya ha votado
  Future<bool> hasUserVoted(String pollId, String userId) async {
    final pollDoc = await _pollsRef.doc(pollId).get();
    final data = pollDoc.data() as Map<String, dynamic>?;
    if (data == null) return false;
    final votedBy = (data['votedBy'] as List?)?.cast<String>() ?? [];
    return votedBy.contains(userId);
  }

  // Votar por una opción (solo si no ha votado)
  Future<bool> vote(String pollId, String optionId, String userId) async {
    final pollRef = _pollsRef.doc(pollId);
    final pollDoc = await pollRef.get();
    final data = pollDoc.data() as Map<String, dynamic>?;
    if (data == null) return false;
    final votedBy = (data['votedBy'] as List?)?.cast<String>() ?? [];
    if (votedBy.contains(userId)) return false;
    try {
      final optionRef = pollRef.collection('options').doc(optionId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(optionRef);
        final currentVotes = (snapshot['votes'] ?? 0) as int;
        transaction.update(optionRef, {'votes': currentVotes + 1});
        transaction.update(pollRef, {
          'votedBy': FieldValue.arrayUnion([userId]),
        });
      });
      return true;
    } catch (e) {
      throw Exception('Error al votar: $e');
    }
  }

  // Eliminar encuesta y sus opciones
  Future<void> deletePoll(String pollId) async {
    try {
      final pollRef = _pollsRef.doc(pollId);
      final optionsSnap = await pollRef.collection('options').get();
      for (final doc in optionsSnap.docs) {
        await doc.reference.delete();
      }
      await pollRef.delete();
    } catch (e) {
      throw Exception('Error al eliminar la encuesta: $e');
    }
  }
}
