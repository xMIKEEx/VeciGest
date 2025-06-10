import 'package:equatable/equatable.dart';

class ThreadModel extends Equatable {
  final String id;
  final String title;
  final String createdBy;
  final DateTime createdAt;
  final List<String> authorizedPropertyIds; // IDs de viviendas autorizadas
  final String? description; // Descripción opcional del chat

  const ThreadModel({
    required this.id,
    required this.title,
    required this.createdBy,
    required this.createdAt,
    this.authorizedPropertyIds = const [],
    this.description,
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
      authorizedPropertyIds:
          (map['authorizedPropertyIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'authorizedPropertyIds': authorizedPropertyIds,
      'description': description,
    };
  }

  ThreadModel copyWith({
    String? title,
    List<String>? authorizedPropertyIds,
    String? description,
  }) {
    return ThreadModel(
      id: id,
      title: title ?? this.title,
      createdBy: createdBy,
      createdAt: createdAt,
      authorizedPropertyIds:
          authorizedPropertyIds ?? this.authorizedPropertyIds,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    createdBy,
    createdAt,
    authorizedPropertyIds,
    description,
  ];
}
