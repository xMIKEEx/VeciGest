import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vecigest/domain/models/message_model.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  const ChatBubble({super.key, required this.message, required this.isMe});
  @override
  Widget build(BuildContext context) {
    const orangeColor = Color(0xFFFF6B35);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe ? orangeColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.senderName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isMe ? Colors.white.withOpacity(0.9) : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
