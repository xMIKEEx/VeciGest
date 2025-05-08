import 'package:equatable/equatable.dart';

class ThreadModel extends Equatable {
  final String id;
  final String title;
  final String createdBy;
  final DateTime createdAt;

  const ThreadModel({
    required this.id,
    required this.title,
    required this.createdBy,
    required this.createdAt,
  });

  factory ThreadModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ThreadModel(
      id: documentId,
      title: map['title'] as String,
      createdBy: map['createdBy'] as String,
      createdAt:
          (map['createdAt'] is DateTime)
              ? map['createdAt'] as DateTime
              : (map['createdAt'] != null && map['createdAt'].toDate != null)
              ? map['createdAt'].toDate() as DateTime
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'createdBy': createdBy, 'createdAt': createdAt};
  }

  ThreadModel copyWith({String? title}) {
    return ThreadModel(
      id: id,
      title: title ?? this.title,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, createdBy, createdAt];
}
