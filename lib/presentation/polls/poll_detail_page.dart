import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vecigest/data/services/poll_service.dart';
import 'package:vecigest/domain/models/poll_model.dart';
import 'package:vecigest/domain/models/poll_option_model.dart';
import 'package:vecigest/utils/routes.dart';

class PollDetailPage extends StatefulWidget {
  final PollModel poll;
  const PollDetailPage({super.key, required this.poll});

  @override
  State<PollDetailPage> createState() => _PollDetailPageState();
}

class _PollDetailPageState extends State<PollDetailPage> {
  final PollService _pollService = PollService();
  User? get _user => FirebaseAuth.instance.currentUser;
  bool _loadingVote = false;
  bool _voted = false;

  Future<void> _checkVoted() async {
    if (_user == null) return;
    final voted = await _pollService.hasUserVoted(widget.poll.id, _user!.uid);
    setState(() => _voted = voted);
  }

  @override
  void initState() {
    super.initState();
    _checkVoted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.poll.question)),
      body: StreamBuilder<List<PollOptionModel>>(
        stream: _pollService.getOptions(widget.poll.id),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(child: Text('Error al cargar opciones'));
          }
          final options = snap.data ?? [];
          final totalVotes = options.fold<int>(0, (sum, o) => sum + o.votes);
          final colors = [
            Colors.blue,
            Colors.green,
            Colors.orange,
            Colors.purple,
            Colors.red,
            Colors.teal,
          ];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Gráfica de barras
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resultados',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        ...options.asMap().entries.map((entry) {
                          final i = entry.key;
                          final o = entry.value;
                          final percent =
                              totalVotes > 0 ? o.votes / totalVotes : 0.0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: colors[i % colors.length]
                                              .withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      FractionallySizedBox(
                                        widthFactor: percent,
                                        child: Container(
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: colors[i % colors.length],
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Center(
                                          child: Text(
                                            '${o.text} (${(percent * 100).toStringAsFixed(1)}%)',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${o.votes}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        Text(
                          'Total de votos: $totalVotes',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (!_voted && _user != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Vota tu opción:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ...options.asMap().entries.map((entry) {
                        final i = entry.key;
                        final o = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors[i % colors.length],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed:
                                _loadingVote
                                    ? null
                                    : () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder:
                                            (ctx) => AlertDialog(
                                              title: const Text(
                                                'Confirmar voto',
                                              ),
                                              content: Text(
                                                '¿Estás seguro de que quieres votar por "${o.text}"?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.of(
                                                        ctx,
                                                      ).pop(false),
                                                  child: const Text('Cancelar'),
                                                ),
                                                ElevatedButton(
                                                  onPressed:
                                                      () => Navigator.of(
                                                        ctx,
                                                      ).pop(true),
                                                  child: const Text('Votar'),
                                                ),
                                              ],
                                            ),
                                      );
                                      if (confirm != true) return;
                                      setState(() => _loadingVote = true);
                                      final ok = await _pollService.vote(
                                        widget.poll.id,
                                        o.id,
                                        _user!.uid,
                                      );
                                      await _checkVoted();
                                      setState(() => _loadingVote = false);
                                      if (!ok) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Ya has votado o hubo un error.',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                            child: Text(
                              o.text,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      }),
                    ],
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Ya has votado en esta encuesta.',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('Ver resultados'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade50,
                    foregroundColor: Colors.deepPurple,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed:
                      () => Navigator.pushNamed(
                        context,
                        AppRoutes.pollResults,
                        arguments: widget.poll,
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
