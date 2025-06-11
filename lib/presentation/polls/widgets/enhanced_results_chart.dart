import 'package:flutter/material.dart';
import 'package:vecigest/domain/models/poll_option_model.dart';

class EnhancedResultsChart extends StatelessWidget {
  final List<PollOptionModel> options;
  final int totalVotes;

  const EnhancedResultsChart({
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
    if (totalVotes == 0) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildCircularChart(),
          const SizedBox(height: 24),
          _buildDetailedResults(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        'Aún no hay votos',
        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCircularChart() {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildBackgroundCircle(),
          ..._buildProgressCircles(),
          _buildCenterText(),
        ],
      ),
    );
  }

  Widget _buildBackgroundCircle() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[100],
      ),
    );
  }

  List<Widget> _buildProgressCircles() {
    return options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      final percentage = option.votes / totalVotes;
      final color = _purpleColors[index % _purpleColors.length];

      return SizedBox(
        width: 160 - (index * 20),
        height: 160 - (index * 20),
        child: CircularProgressIndicator(
          value: percentage,
          strokeWidth: 8,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }).toList();
  }

  Widget _buildCenterText() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$totalVotes',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        Text('votos', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildDetailedResults() {
    return Column(
      children:
          options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final percentage = totalVotes > 0 ? option.votes / totalVotes : 0.0;
            final color = _purpleColors[index % _purpleColors.length];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          option.text,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '${option.votes} votos (${(percentage * 100).toStringAsFixed(1)}%)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
