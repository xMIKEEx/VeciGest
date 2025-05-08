import 'package:flutter/material.dart';
import 'package:vecigest/data/services/chat_service.dart';
import 'package:vecigest/domain/models/thread_model.dart';
import 'package:vecigest/utils/routes.dart';
import 'package:timeago/timeago.dart' as timeago;

class ThreadListPage extends StatefulWidget {
  const ThreadListPage({Key? key}) : super(key: key);

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
    return Scaffold(
      appBar: AppBar(title: const Text('Foros')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: StreamBuilder<List<ThreadModel>>(
          stream: _threadsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
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
              return const Center(child: Text('No hay hilos disponibles.'));
            }
            final threads = snapshot.data!;
            return ListView.separated(
              itemCount: threads.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final thread = threads[index];
                return ListTile(
                  title: Text(thread.title),
                  subtitle: Text(timeago.format(thread.createdAt)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.chatMessages, // Changed from AppRoutes.chat
                      arguments: thread,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
