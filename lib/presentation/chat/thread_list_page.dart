import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vecigest/data/services/chat_service.dart';
import 'package:vecigest/data/services/user_role_service.dart';
import 'package:vecigest/domain/models/thread_model.dart';
import 'package:vecigest/utils/routes.dart';
import 'package:vecigest/presentation/chat/widgets/chat_card.dart';
import 'package:vecigest/presentation/chat/widgets/chat_states.dart';
import 'package:vecigest/presentation/chat/new_chat_group_page.dart';

class ThreadListPage extends StatefulWidget {
  final Function(Widget)? onNavigate;

  const ThreadListPage({super.key, this.onNavigate});

  @override
  State<ThreadListPage> createState() => _ThreadListPageState();
}

class _ThreadListPageState extends State<ThreadListPage> {
  final ChatService _chatService = ChatService();
  final UserRoleService _userRoleService = UserRoleService();

  late Stream<List<ThreadModel>> _threadsStream;
  bool _isAdmin = false;
  String? _communityId;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Verificar si es admin y obtener communityId
        final userRole = await _userRoleService.getUserRoleAndCommunity(
          user.uid,
        );

        setState(() {
          _isAdmin = userRole?['role'] == 'admin';
          _communityId = userRole?['communityId'];
          _isInitialized = true;
        });

        // Configurar el stream apropiado
        if (_isAdmin) {
          _threadsStream = _chatService.getThreads();
        } else if (_communityId != null) {
          _threadsStream = _chatService.getThreadsForUser(
            user.uid,
            _communityId!,
          );
        } else {
          // Si no tiene comunidad, crear un stream vacío
          _threadsStream = Stream.value(<ThreadModel>[]);
        }
      } catch (e) {
        setState(() {
          _isInitialized = true;
          _threadsStream = Stream.value(<ThreadModel>[]);
        });
      }
    } else {
      setState(() {
        _isInitialized = true;
        _threadsStream = Stream.value(<ThreadModel>[]);
      });
    }
  }

  Future<void> _refresh() async {
    await _initializeData();
  }

  void _navigateToNewChatGroup() {
    if (widget.onNavigate != null) {
      widget.onNavigate!(const NewChatGroupPage());
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NewChatGroupPage()),
      ).then((result) {
        if (result == true) {
          _refresh();
        }
      });
    }
  }

  void _navigateToChat(ThreadModel thread) {
    Navigator.pushNamed(context, AppRoutes.chatMessages, arguments: thread);
  }

  Future<void> _showDeleteConfirmation(ThreadModel thread) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar Chat'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Estás seguro de que quieres eliminar el chat "${thread.title}"?',
                ),
                const SizedBox(height: 12),
                const Text(
                  'Esta acción eliminará permanentemente el chat y todos sus mensajes.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (result == true) {
      await _deleteThread(thread);
    }
  }

  Future<void> _deleteThread(ThreadModel thread) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await _chatService.deleteThread(thread.id);

      // Cerrar indicador de carga
      if (mounted) Navigator.of(context).pop();

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chat "${thread.title}" eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Cerrar indicador de carga si está abierto
      if (mounted) Navigator.of(context).pop();

      // Mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar el chat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [_buildSliverAppBar(theme)],
        body: _buildBody(),
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Chats',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 60,
                right: -20,
                child: Icon(
                  Icons.chat_bubble,
                  size: 120,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              Positioned(
                bottom: 60,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comunícate con',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'tu comunidad',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton(ThemeData theme) {
    if (!_isAdmin) return null;

    return FloatingActionButton.extended(
      onPressed: _navigateToNewChatGroup,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.group_add),
      label: const Text(
        'Nuevo Chat Grupal',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      elevation: 8,
    );
  }

  Widget _buildBody() {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<List<ThreadModel>>(
      stream: _threadsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ChatStates.buildLoadingState();
        }

        if (snapshot.hasError) {
          return ChatStates.buildErrorState(context, _refresh);
        }

        final threads = snapshot.data ?? [];

        if (threads.isEmpty) {
          return ChatStates.buildEmptyState(
            context,
            _isAdmin,
            _navigateToNewChatGroup,
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: threads.length,
            itemBuilder:
                (context, index) =>
                    _buildChatCardWrapper(threads[index], index),
          ),
        );
      },
    );
  }

  Widget _buildChatCardWrapper(ThreadModel thread, int index) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getThreadMetadata(thread.id),
      builder: (context, snapshot) {
        final metadata =
            snapshot.data ?? {'messageCount': 0, 'hasUnread': false};
        final messageCount = metadata['messageCount'] as int;
        final hasUnreadMessages = metadata['hasUnread'] as bool;

        return ChatCard(
          thread: thread,
          index: index,
          messageCount: messageCount,
          hasUnreadMessages: hasUnreadMessages,
          onCardTap: () => _navigateToChat(thread),
          isAdmin: _isAdmin,
          onDelete: _isAdmin ? () => _showDeleteConfirmation(thread) : null,
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getThreadMetadata(String threadId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'messageCount': 0, 'hasUnread': false};
    }

    try {
      final messageCountFuture = _chatService.getMessageCount(threadId);
      final hasUnreadFuture = _chatService.hasUnreadMessages(
        threadId,
        user.uid,
      );

      final results = await Future.wait([messageCountFuture, hasUnreadFuture]);

      return {
        'messageCount': results[0] as int,
        'hasUnread': results[1] as bool,
      };
    } catch (e) {
      return {'messageCount': 0, 'hasUnread': false};
    }
  }
}
