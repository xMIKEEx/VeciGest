import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vecigest/domain/models/message_model.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isMe
                  ? theme.colorScheme.primary.withOpacity(0.15)
                  : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.senderName,
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 2),
            Text(message.content),
            const SizedBox(height: 2),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
