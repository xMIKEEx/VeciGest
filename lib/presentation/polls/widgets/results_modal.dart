import 'package:flutter/material.dart';
import 'package:vecigest/domain/models/poll_model.dart';
import 'package:vecigest/presentation/polls/widgets/enhanced_results_chart.dart';

class ResultsModal extends StatelessWidget {
  final PollModel poll;

  const ResultsModal({super.key, required this.poll});

  @override
  Widget build(BuildContext context) {
    final totalVotes = poll.options.fold<int>(
      0,
      (sum, option) => sum + option.votes,
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandleBar(),
          const SizedBox(height: 20),
          _buildTitle(),
          const SizedBox(height: 8),
          _buildSubtitle(totalVotes),
          const SizedBox(height: 24),
          EnhancedResultsChart(options: poll.options, totalVotes: totalVotes),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        poll.question,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSubtitle(int totalVotes) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'Resultados de la votación • $totalVotes votos',
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        textAlign: TextAlign.center,
      ),
    );
  }
}
