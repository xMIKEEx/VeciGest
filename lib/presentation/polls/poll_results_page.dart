import 'package:flutter/material.dart';
import 'package:vecigest/data/services/poll_service.dart';
import 'package:vecigest/domain/models/poll_model.dart';
import 'package:vecigest/domain/models/poll_option_model.dart';

class PollResultsPage extends StatelessWidget {
  final PollModel poll;
  const PollResultsPage({super.key, required this.poll});

  @override
  Widget build(BuildContext context) {
    final PollService pollService = PollService();
    return Scaffold(
      appBar: AppBar(title: Text('Resultados')),
      body: FutureBuilder<List<PollOptionModel>>(
        future: pollService.getOptions(poll.id).first,
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final options = snap.data!;
          final totalVotes = options.fold<int>(0, (sum, o) => sum + o.votes);
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resultados de: ${poll.question}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ...options.map(
                  (o) => ListTile(
                    title: Text(o.text),
                    subtitle: LinearProgressIndicator(
                      value: totalVotes > 0 ? o.votes / totalVotes : 0,
                      minHeight: 8,
                    ),
                    trailing: Text('${o.votes}'),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Total de votos: $totalVotes'),
              ],
            ),
          );
        },
      ),
    );
  }
}
