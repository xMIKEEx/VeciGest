import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vecigest/data/services/poll_service.dart';
import 'package:vecigest/domain/models/poll_model.dart';
import 'package:vecigest/utils/routes.dart';
import 'package:vecigest/presentation/polls/poll_detail_page.dart';

class PollListPage extends StatefulWidget {
  final Function(Widget)? onNavigate;

  const PollListPage({super.key, this.onNavigate});

  @override
  State<PollListPage> createState() => _PollListPageState();
}

class _PollListPageState extends State<PollListPage> {
  final PollService _pollService = PollService();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surface,
      child: StreamBuilder<List<PollModel>>(
        stream: _pollService.getPolls(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 6,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
          }
          if (snap.hasError) {
            return const Center(child: Text('Error al cargar encuestas'));
          }
          final polls = snap.data ?? [];
          if (polls.isEmpty) {
            return Center(
              child: Text(
                'No hay encuestas disponibles',
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
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
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 22,
                  ),
                  title: Text(
                    poll.question,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.how_to_vote,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          totalVotes == 1 ? '1 voto' : '$totalVotes votos',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 28),
                  onTap: () {
                    if (widget.onNavigate != null) {
                      widget.onNavigate!(PollDetailPage(poll: poll));
                    } else {
                      Navigator.pushNamed(
                        ctx,
                        AppRoutes.pollDetail,
                        arguments: poll,
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
