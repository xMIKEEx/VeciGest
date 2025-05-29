import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vecigest/data/services/chat_service.dart';
import 'package:vecigest/domain/models/thread_model.dart';
import 'package:vecigest/utils/routes.dart';
import 'package:vecigest/presentation/chat/chat_page.dart';
import 'package:vecigest/presentation/chat/new_thread_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class ThreadListPage extends StatefulWidget {
  final Function(Widget)? onNavigate;

  const ThreadListPage({super.key, this.onNavigate});

  @override
  State<ThreadListPage> createState() => _ThreadListPageState();
}

class _ThreadListPageState extends State<ThreadListPage> {
  late Stream<List<ThreadModel>> _threadsStream;

  @override
  void initState() {
    super.initState();
    _threadsStream = ChatService().getThreads();
  }

  Future<void> _refresh() async {
    setState(() {
      _threadsStream = ChatService().getThreads();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: StreamBuilder<List<ThreadModel>>(
          stream: _threadsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                itemCount: 6,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                itemBuilder:
                    (_, __) => Shimmer.fromColors(
                      baseColor: colorScheme.surfaceContainerHighest,
                      highlightColor: colorScheme.surface,
                      child: Container(
                        height: 80,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Error al cargar los hilos'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No hay hilos disponibles.',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              );
            }
            final threads = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: threads.length,
              itemBuilder: (context, index) {
                final thread = threads[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 22,
                    ),
                    title: Text(
                      thread.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        timeago.format(thread.createdAt),
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 28),
                    onTap: () {
                      if (widget.onNavigate != null) {
                        widget.onNavigate!(ChatPage(thread: thread));
                      } else {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.chatMessages,
                          arguments: thread,
                        );
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_thread_list',
        onPressed: () {
          if (widget.onNavigate != null) {
            widget.onNavigate!(const NewThreadPage());
          } else {
            Navigator.pushNamed(context, AppRoutes.newThread);
          }
        },
        tooltip: 'Añadir hilo',
        child: const Icon(Icons.add),
      ),
    );
  }
}
