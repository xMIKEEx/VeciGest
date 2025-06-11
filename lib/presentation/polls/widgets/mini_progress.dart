import 'package:flutter/material.dart';
import 'package:vecigest/domain/models/poll_option_model.dart';

class MiniProgress extends StatelessWidget {
  final List<PollOptionModel> options;
  final int totalVotes;

  const MiniProgress({
    super.key,
    required this.options,
    required this.totalVotes,
  });
  // Purple color variations for different poll options
  static const List<Color> _purpleColors = [
    Color(0xFF9C27B0), // Primary purple
    Color(0xFF7B1FA2), // Darker purple
    Color(0xFFBA68C8), // Lighter purple
    Color(0xFF673AB7), // Deep purple
    Color(0xFFCE93D8), // Very light purple
    Color(0xFF8E24AA), // Purple variant
  ];

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty || totalVotes == 0) return const SizedBox.shrink();

    return Column(
      children: [
        _buildProgressBar(),
        const SizedBox(height: 8),
        _buildTopOptions(),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Row(
          children:
              options.asMap().entries.where((e) => e.value.votes > 0).map((
                entry,
              ) {
                final index = entry.key;
                final option = entry.value;
                final percentage = option.votes / totalVotes;
                final color = _purpleColors[index % _purpleColors.length];

                return Flexible(
                  flex: (percentage * 1000).round(),
                  child: Container(height: 8, color: color),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildTopOptions() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children:
          options.take(3).map((option) {
            final index = options.indexOf(option);
            final color = _purpleColors[index % _purpleColors.length];
            final percentage =
                totalVotes > 0 ? (option.votes / totalVotes * 100) : 0;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${option.text}: ${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
