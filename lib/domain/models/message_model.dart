import 'package:equatable/equatable.dart';

class MessageModel extends Equatable {
  final String id;
  final String threadId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;

  const MessageModel({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
  });

  factory MessageModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
    String threadId,
  ) {
    return MessageModel(
      id: documentId,
      threadId: threadId,
      senderId: map['senderId'] as String,
      senderName: map['senderName'] as String,
      content: map['content'] as String,
      timestamp:
          (map['timestamp'] is DateTime)
              ? map['timestamp'] as DateTime
              : (map['timestamp'] != null && map['timestamp'].toDate != null)
              ? map['timestamp'].toDate() as DateTime
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp,
    };
  }

  MessageModel copyWith({String? content}) {
    return MessageModel(
      id: id,
      threadId: threadId,
      senderId: senderId,
      senderName: senderName,
      content: content ?? this.content,
      timestamp: timestamp,
    );
  }

  @override
  List<Object?> get props => [
    id,
    threadId,
    senderId,
    senderName,
    content,
    timestamp,
  ];
}
