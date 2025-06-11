import 'package:flutter/material.dart';
import 'package:vecigest/domain/models/poll_model.dart';
import 'package:vecigest/domain/models/poll_option_model.dart';

class VotingModal extends StatelessWidget {
  final PollModel poll;
  final Function(PollModel poll, PollOptionModel option) onVote;

  const VotingModal({super.key, required this.poll, required this.onVote});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandleBar(),
          const SizedBox(height: 20),
          _buildTitle(),
          const SizedBox(height: 8),
          _buildSubtitle(),
          const SizedBox(height: 24),
          _buildOptions(),
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
        color: Colors.purple.shade600.withOpacity(0.3),
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

  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'Selecciona una opción para votar',
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOptions() {
    if (poll.options.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: Colors.purple.shade600,
              ),
              const SizedBox(height: 12),
              Text(
                'No hay opciones disponibles',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Esta encuesta no tiene opciones de votación configuradas.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children:
          poll.options.map((option) {
            final purpleColor = Colors.purple.shade600;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    onVote(poll, option);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: purpleColor.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(16),
                      color: purpleColor.withOpacity(0.1),
                      boxShadow: [
                        BoxShadow(
                          color: purpleColor.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: purpleColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            option.text,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
