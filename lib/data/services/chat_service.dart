import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecigest/domain/models/thread_model.dart';
import 'package:vecigest/domain/models/message_model.dart';
import 'package:vecigest/domain/models/user_model.dart';
import 'package:vecigest/data/services/property_service.dart';

class ChatService {
  final FirebaseFirestore _firestore;
  final PropertyService _propertyService;
  static ChatService? _instance;

  ChatService._(this._firestore, this._propertyService);

  factory ChatService({
    FirebaseFirestore? firestore,
    PropertyService? propertyService,
  }) {
    _instance ??= ChatService._(
      firestore ?? FirebaseFirestore.instance,
      propertyService ?? PropertyService(),
    );
    return _instance!;
  }
  // Escucha hilos disponibles para el usuario basado en sus viviendas
  Stream<List<ThreadModel>> getThreadsForUser(
    String userId,
    String communityId,
  ) {
    return _firestore
        .collection('threads')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final threads = <ThreadModel>[];

          for (final doc in snapshot.docs) {
            final thread = ThreadModel.fromMap(doc.data(), doc.id);

            // Verificar si el usuario tiene acceso a este thread
            final hasAccess = await _userHasAccessToThread(
              userId,
              communityId,
              thread,
            );
            if (hasAccess) {
              threads.add(thread);
            }
          }

          return threads;
        });
  }

  // Verifica si un usuario tiene acceso a un thread específico
  Future<bool> _userHasAccessToThread(
    String userId,
    String communityId,
    ThreadModel thread,
  ) async {
    // Si no hay viviendas autorizadas especificadas, es un chat público
    if (thread.authorizedPropertyIds.isEmpty) {
      return true;
    }

    // Verificar si el usuario vive en alguna de las viviendas autorizadas
    try {
      final userProperties = await _propertyService.getUserProperties(
        communityId,
        userId,
      );
      final userPropertyIds = userProperties.map((p) => p.viviendaId).toList();

      return thread.authorizedPropertyIds.any(
        (authorizedId) => userPropertyIds.contains(authorizedId),
      );
    } catch (e) {
      return false;
    }
  }

  // Escucha todos los hilos (solo para admins)
  Stream<List<ThreadModel>> getThreads() {
    try {
      return _firestore
          .collection('threads')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => ThreadModel.fromMap(doc.data(), doc.id))
                    .toList(),
          );
    } catch (e) {
      throw Exception('Error al obtener los hilos: $e');
    }
  }

  // Crea un nuevo hilo con viviendas autorizadas
  Future<ThreadModel> createThread(
    String title,
    UserModel creator,
    List<String> authorizedPropertyIds, {
    String? description,
  }) async {
    try {
      final threadData = {
        'title': title,
        'createdBy': creator.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'authorizedPropertyIds': authorizedPropertyIds,
        'description': description,
      };
      final docRef = await _firestore.collection('threads').add(threadData);
      final doc = await docRef.get();
      return ThreadModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Error al crear el hilo: $e');
    }
  }

  // Escucha mensajes de un hilo ordenados por timestamp ascendente
  Stream<List<MessageModel>> getMessages(String threadId) {
    try {
      return _firestore
          .collection('threads')
          .doc(threadId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map(
                      (doc) =>
                          MessageModel.fromMap(doc.data(), doc.id, threadId),
                    )
                    .toList(),
          );
    } catch (e) {
      throw Exception('Error al obtener los mensajes: $e');
    }
  }

  // Añade un mensaje a la subcolección
  Future<void> sendMessage(String threadId, MessageModel message) async {
    try {
      await _firestore
          .collection('threads')
          .doc(threadId)
          .collection('messages')
          .add(message.toMap());
    } catch (e) {
      throw Exception('Error al enviar el mensaje: $e');
    }
  }

  // Elimina un hilo de chat y todos sus mensajes (solo para admins)
  Future<void> deleteThread(String threadId) async {
    try {
      final threadRef = _firestore.collection('threads').doc(threadId);

      // Primero eliminar todos los mensajes de la subcolección
      final messagesSnapshot = await threadRef.collection('messages').get();
      final batch = _firestore.batch();

      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Luego eliminar el hilo principal
      batch.delete(threadRef);

      // Ejecutar todas las eliminaciones
      await batch.commit();
    } catch (e) {
      throw Exception('Error al eliminar el hilo: $e');
    }
  }

  // Obtiene el conteo de mensajes en un hilo
  Future<int> getMessageCount(String threadId) async {
    try {
      final messagesSnapshot =
          await _firestore
              .collection('threads')
              .doc(threadId)
              .collection('messages')
              .get();
      return messagesSnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // Verifica si hay mensajes no leídos en un hilo para un usuario
  // Para simplificar, consideramos como "no leído" si hay mensajes
  // enviados en las últimas 24 horas por otros usuarios
  Future<bool> hasUnreadMessages(String threadId, String userId) async {
    try {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      final recentMessagesSnapshot =
          await _firestore
              .collection('threads')
              .doc(threadId)
              .collection('messages')
              .where('timestamp', isGreaterThan: Timestamp.fromDate(yesterday))
              .where('senderId', isNotEqualTo: userId)
              .get();

      return recentMessagesSnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
