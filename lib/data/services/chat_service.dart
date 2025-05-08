import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecigest/domain/models/thread_model.dart';
import 'package:vecigest/domain/models/message_model.dart';
import 'package:vecigest/domain/models/user_model.dart';

class ChatService {
  final FirebaseFirestore _firestore;
  static ChatService? _instance;

  ChatService._(this._firestore);

  factory ChatService({FirebaseFirestore? firestore}) {
    _instance ??= ChatService._(firestore ?? FirebaseFirestore.instance);
    return _instance!;
  }

  // Escucha en tiempo real todos los hilos ordenados por createdAt descendente
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

  // Crea un nuevo hilo y devuelve el ThreadModel
  Future<ThreadModel> createThread(String title, UserModel creator) async {
    try {
      final docRef = await _firestore.collection('threads').add({
        'title': title,
        'createdBy': creator.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
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
}
