import 'package:firebase_auth/firebase_auth.dart';
import 'package:vecigest/data/services/poll_service.dart';
import 'package:vecigest/domain/models/poll_model.dart';

class PollBusinessLogic {
  final PollService _pollService = PollService();

  Future<List<PollModel>> filterPolls(
    List<PollModel> polls,
    String filter,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    List<PollModel> filtered = polls;

    // Apply vote filter
    if (filter == 'voted' || filter == 'unvoted') {
      final List<PollModel> result = [];
      for (final poll in filtered) {
        final hasVoted = await hasUserVoted(poll.id);
        if ((filter == 'voted' && hasVoted) ||
            (filter == 'unvoted' && !hasVoted)) {
          result.add(poll);
        }
      }
      return result;
    }

    return filtered;
  }

  Future<bool> hasUserVoted(String pollId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    return await _pollService.hasUserVoted(pollId, user.uid);
  }

  Future<void> voteForOption(String pollId, String optionId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    await _pollService.vote(pollId, optionId, user.uid);
  }
}
