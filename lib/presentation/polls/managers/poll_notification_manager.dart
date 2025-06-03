import 'package:flutter/material.dart';
import 'package:vecigest/domain/models/poll_model.dart';
import 'package:vecigest/data/services/poll_service.dart';

class PollNotificationManager {
  final PollService _pollService;

  PollNotificationManager(this._pollService);

  /// Filtrar encuestas sin votar para un usuario específico
  Future<List<PollModel>> getUnvotedPolls(
    List<PollModel> allPolls,
    String userId,
  ) async {
    final List<PollModel> unvotedPolls = [];

    for (final poll in allPolls) {
      try {
        final hasVoted = await _pollService.hasUserVoted(poll.id, userId);
        if (!hasVoted) {
          unvotedPolls.add(poll);
        }
      } catch (e) {
        // Si hay error al verificar el voto, incluir la encuesta por seguridad
        unvotedPolls.add(poll);
      }
    }

    return unvotedPolls;
  }

  /// Navegar a la página de detalles de una encuesta específica
  void navigateToPollDetail(BuildContext context, PollModel poll) {
    Navigator.pushNamed(context, '/poll-detail', arguments: poll);
  }
}
