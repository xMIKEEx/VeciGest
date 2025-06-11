import 'package:equatable/equatable.dart';
import 'package:vecigest/domain/models/thread_model.dart';

class ChatNotification extends Equatable {
  final String id;
  final String threadId;
  final String threadTitle;
  final int unreadCount;
  final DateTime lastMessageTime;
  final String lastMessageSender;
  final String lastMessageContent;
  final bool isVisible;

  const ChatNotification({
    required this.id,
    required this.threadId,
    required this.threadTitle,
    required this.unreadCount,
    required this.lastMessageTime,
    required this.lastMessageSender,
    required this.lastMessageContent,
    this.isVisible = true,
  });

  factory ChatNotification.fromThread(
    ThreadModel thread,
    int unreadCount,
    DateTime lastMessageTime,
    String lastMessageSender,
    String lastMessageContent,
  ) {
    return ChatNotification(
      id: '${thread.id}_notification',
      threadId: thread.id,
      threadTitle: thread.title,
      unreadCount: unreadCount,
      lastMessageTime: lastMessageTime,
      lastMessageSender: lastMessageSender,
      lastMessageContent: lastMessageContent,
    );
  }

  ChatNotification copyWith({bool? isVisible, int? unreadCount}) {
    return ChatNotification(
      id: id,
      threadId: threadId,
      threadTitle: threadTitle,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageTime: lastMessageTime,
      lastMessageSender: lastMessageSender,
      lastMessageContent: lastMessageContent,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  @override
  List<Object?> get props => [
    id,
    threadId,
    threadTitle,
    unreadCount,
    lastMessageTime,
    lastMessageSender,
    lastMessageContent,
    isVisible,
  ];
}
