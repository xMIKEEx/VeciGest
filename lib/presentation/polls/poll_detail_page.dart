import 'package:flutter/material.dart';
import 'package:vecigest/data/services/poll_service.dart';
import 'package:vecigest/domain/models/poll_model.dart';
import 'package:vecigest/domain/models/poll_option_model.dart';
import 'package:vecigest/utils/routes.dart';

class PollDetailPage extends StatefulWidget {
  final PollModel poll;
  const PollDetailPage({Key? key, required this.poll}) : super(key: key);

  @override
  State<PollDetailPage> createState() => _PollDetailPageState();
}

class _PollDetailPageState extends State<PollDetailPage> {
  final PollService _pollService = PollService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.poll.question)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<PollOptionModel>>(
              stream: _pollService.getOptions(widget.poll.id),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return const Center(child: Text('Error al cargar opciones'));
                }
                final options = snap.data ?? [];
                return ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (ctx, i) {
                    final opt = options[i];
                    return ListTile(
                      title: Text(opt.text),
                      trailing: Text('${opt.votes}'),
                      onTap: () => _pollService.vote(widget.poll.id, opt.id),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.bar_chart),
              label: const Text('Ver resultados'),
              onPressed:
                  () => Navigator.pushNamed(
                    context,
                    AppRoutes.pollResults,
                    arguments: widget.poll,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
