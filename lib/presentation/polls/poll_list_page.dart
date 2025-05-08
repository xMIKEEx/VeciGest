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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.background,
      child: StreamBuilder<List<PollModel>>(
        stream: _pollService.getPolls(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(child: Text('Error al cargar encuestas'));
          }
          final polls = snap.data ?? [];
          if (polls.isEmpty) {
            return Center(
              child: Text(
                'No hay encuestas disponibles',
                style: TextStyle(
                  color: colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            itemCount: polls.length,
            itemBuilder: (ctx, i) {
              final poll = polls[i];
              final totalVotes = poll.options.fold<int>(
                0,
                (sum, o) => sum + o.votes,
              );
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  title: Text(
                    poll.question,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.how_to_vote,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          totalVotes == 1 ? '1 voto' : '$totalVotes votos',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 28),
                  onTap:
                      () => Navigator.pushNamed(
                        ctx,
                        AppRoutes.pollDetail,
                        arguments: poll,
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
