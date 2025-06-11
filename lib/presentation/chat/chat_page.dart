import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vecigest/data/services/chat_service.dart';
import 'package:vecigest/domain/models/thread_model.dart';
import 'package:vecigest/domain/models/message_model.dart';

class ChatPage extends StatefulWidget {
  final ThreadModel thread;
  const ChatPage({super.key, required this.thread});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const orangeColor = Color(0xFFFF6B35);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.thread.title),
        backgroundColor: orangeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                orangeColor,
                orangeColor.withOpacity(0.9),
                const Color(0xFFE85A2B),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.getMessages(widget.thread.id),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return const Center(child: Text('Error al cargar mensajes'));
                }
                final messages = snap.data ?? [];
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );
                  }
                });
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder:
                      (_, i) => ChatBubble(
                        message: messages[i],
                        isMe:
                            messages[i].senderId ==
                            FirebaseAuth.instance.currentUser?.uid,
                      ),
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: orangeColor.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Escribe un mensaje...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: orangeColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        final text = _controller.text.trim();
                        if (text.isEmpty) return;
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return;
                        final msg = MessageModel(
                          id: '', // Firestore auto
                          threadId: widget.thread.id,
                          senderId: user.uid,
                          senderName: user.displayName ?? '',
                          content: text,
                          timestamp: DateTime.now(),
                        );
                        _chatService.sendMessage(widget.thread.id, msg);
                        _controller.clear();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
                fontWeight: FontWeight.bold,
                fontSize: 12,
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
              _formatTime(message.timestamp),
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

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
