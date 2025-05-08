import 'package:equatable/equatable.dart';

class PollOptionModel extends Equatable {
  final String id;
  final String text;
  final int votes;
  final String pollId;

  const PollOptionModel({
    required this.id,
    required this.text,
    required this.votes,
    required this.pollId,
  });

  factory PollOptionModel.fromMap(
    Map<String, dynamic> map,
    String id,
    String pollId,
  ) {
    return PollOptionModel(
      id: id,
      text: map['text'] as String,
      votes:
          (map['votes'] is int)
              ? map['votes'] as int
              : int.tryParse(map['votes'].toString()) ?? 0,
      pollId: pollId,
    );
  }

  Map<String, dynamic> toMap() {
    return {'text': text, 'votes': votes};
  }

  PollOptionModel copyWith({String? text, int? votes}) {
    return PollOptionModel(
      id: id,
      text: text ?? this.text,
      votes: votes ?? this.votes,
      pollId: pollId,
    );
  }

  @override
  List<Object?> get props => [id, text, votes, pollId];
}
