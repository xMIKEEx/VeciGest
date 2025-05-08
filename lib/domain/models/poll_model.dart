import 'package:equatable/equatable.dart';
import 'poll_option_model.dart';

class PollModel extends Equatable {
  final String id;
  final String question;
  final String createdBy;
  final DateTime createdAt;
  final List<PollOptionModel> options;

  const PollModel({
    required this.id,
    required this.question,
    required this.createdBy,
    required this.createdAt,
    required this.options,
  });

  factory PollModel.fromMap(
    Map<String, dynamic> map,
    String id, {
    List<PollOptionModel> options = const [],
  }) {
    return PollModel(
      id: id,
      question: map['question'] as String,
      createdBy: map['createdBy'] as String,
      createdAt:
          (map['createdAt'] is DateTime)
              ? map['createdAt'] as DateTime
              : (map['createdAt'] != null && map['createdAt'].toDate != null)
              ? map['createdAt'].toDate() as DateTime
              : DateTime.now(),
      options: options,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }

  PollModel copyWith({String? question, List<PollOptionModel>? options}) {
    return PollModel(
      id: id,
      question: question ?? this.question,
      createdBy: createdBy,
      createdAt: createdAt,
      options: options ?? this.options,
    );
  }

  @override
  List<Object?> get props => [id, question, createdBy, createdAt, options];
}
