import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecigest/domain/models/chat_notification_model.dart';
import 'package:vecigest/domain/models/thread_model.dart';
import 'package:vecigest/domain/models/message_model.dart';
import 'package:vecigest/data/services/chat_service.dart';
import 'package:vecigest/data/services/user_role_service.dart';

class ChatNotificationService {
  final ChatService _chatService = ChatService();
  final UserRoleService _userRoleService = UserRoleService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtiene las notificaciones de chat visibles para un usuario
  Stream<List<ChatNotification>> getVisibleNotificationsForUser(
    String userId,
    String communityId, {
    int limit = 10,
  }) async* {
    try {
      // Determine if user is admin
      final userRole = await _userRoleService.getUserRoleAndCommunity(userId);
      final isAdmin = userRole?['role'] == 'admin';

      // Get appropriate threads stream
      Stream<List<ThreadModel>> threadsStream;
      if (isAdmin) {
        threadsStream = _chatService.getThreads();
      } else {
        threadsStream = _chatService.getThreadsForUser(userId, communityId);
      }

      await for (final threads in threadsStream) {
        final notifications = <ChatNotification>[];

        for (final thread in threads.take(limit)) {
          // Get unread count for this thread
          final hasUnread = await _chatService.hasUnreadMessages(
            thread.id,
            userId,
          );

          if (hasUnread) {
            // Get last message info
            final lastMessage = await _getLastMessage(thread.id);

            if (lastMessage != null) {
              // Get message count as unread count approximation
              final messageCount = await _chatService.getMessageCount(
                thread.id,
              );

              final notification = ChatNotification.fromThread(
                thread,
                messageCount,
                lastMessage.timestamp,
                lastMessage.senderName,
                lastMessage.content,
              );

              notifications.add(notification);
            }
          }
        }

        // Sort by last message time (most recent first)
        notifications.sort(
          (a, b) => b.lastMessageTime.compareTo(a.lastMessageTime),
        );

        yield notifications;
      }
    } catch (e) {
      yield [];
    }
  }

  /// Obtiene el último mensaje de un hilo
  Future<MessageModel?> _getLastMessage(String threadId) async {
    try {
      final snapshot =
          await _firestore
              .collection('threads')
              .doc(threadId)
              .collection('messages')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return MessageModel.fromMap(doc.data(), doc.id, threadId);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Obtiene estadísticas de chat para un usuario
  Future<Map<String, int>> getChatStats(
    String userId,
    String communityId,
  ) async {
    try {
      final userRole = await _userRoleService.getUserRoleAndCommunity(userId);
      final isAdmin = userRole?['role'] == 'admin';

      Stream<List<ThreadModel>> threadsStream;
      if (isAdmin) {
        threadsStream = _chatService.getThreads();
      } else {
        threadsStream = _chatService.getThreadsForUser(userId, communityId);
      }

      final threads = await threadsStream.first;
      int totalUnreadGroups = 0;
      int totalUnreadMessages = 0;

      for (final thread in threads) {
        final hasUnread = await _chatService.hasUnreadMessages(
          thread.id,
          userId,
        );
        if (hasUnread) {
          totalUnreadGroups++;
          final messageCount = await _chatService.getMessageCount(thread.id);
          totalUnreadMessages += messageCount;
        }
      }

      return {
        'unreadGroups': totalUnreadGroups,
        'totalMessages': totalUnreadMessages,
        'totalGroups': threads.length,
      };
    } catch (e) {
      return {'unreadGroups': 0, 'totalMessages': 0, 'totalGroups': 0};
    }
  }
}
