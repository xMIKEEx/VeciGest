import 'package:flutter/material.dart';
import 'package:vecigest/data/services/poll_service.dart';
import 'package:vecigest/domain/models/poll_model.dart';
import 'package:vecigest/utils/routes.dart';

class PollListPage extends StatefulWidget {
  const PollListPage({Key? key}) : super(key: key);

  @override
  State<PollListPage> createState() => _PollListPageState();
}

class _PollListPageState extends State<PollListPage> {
  final PollService _pollService = PollService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encuestas')),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_poll_list',
        onPressed: () => Navigator.pushNamed(context, AppRoutes.newPoll),
        child: const Icon(Icons.add),
        tooltip: 'Nueva encuesta',
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<List<PollModel>>(
      stream: _pollService.getPolls(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return const Center(child: Text('Error al cargar encuestas'));
        }
        final polls = snap.data ?? [];
        return ListView.separated(
          itemCount: polls.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (ctx, i) {
            final poll = polls[i];
            return ListTile(
              title: Text(poll.question),
              subtitle: Text(
                '${poll.options.fold<int>(0, (sum, o) => sum + o.votes)} votos',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap:
                  () => Navigator.pushNamed(
                    ctx,
                    AppRoutes.pollDetail,
                    arguments: poll,
                  ),
            );
          },
        );
      },
    );
  }
}
