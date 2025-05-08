import 'package:equatable/equatable.dart';

class IncidentModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final String? assignedTo;
  final String status; // 'open', 'in_progress', 'closed'
  final List<String>? photosUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const IncidentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    this.assignedTo,
    required this.status,
    this.photosUrls,
    required this.createdAt,
    this.updatedAt,
  });

  factory IncidentModel.fromMap(Map<String, dynamic> map, String id) {
    return IncidentModel(
      id: id,
      title: map['title'] as String,
      description: map['description'] as String,
      createdBy: map['createdBy'] as String,
      assignedTo: map['assignedTo'] as String?,
      status: map['status'] as String,
      photosUrls:
          (map['photosUrls'] as List?)?.map((e) => e as String).toList(),
      createdAt:
          (map['createdAt'] is DateTime)
              ? map['createdAt'] as DateTime
              : (map['createdAt'] != null && map['createdAt'].toDate != null)
              ? map['createdAt'].toDate() as DateTime
              : DateTime.now(),
      updatedAt:
          (map['updatedAt'] is DateTime)
              ? map['updatedAt'] as DateTime
              : (map['updatedAt'] != null && map['updatedAt'].toDate != null)
              ? map['updatedAt'].toDate() as DateTime
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'assignedTo': assignedTo,
      'status': status,
      'photosUrls': photosUrls,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  IncidentModel copyWith({
    String? status,
    List<String>? photosUrls,
    String? assignedTo,
    DateTime? updatedAt,
  }) {
    return IncidentModel(
      id: id,
      title: title,
      description: description,
      createdBy: createdBy,
      assignedTo: assignedTo ?? this.assignedTo,
      status: status ?? this.status,
      photosUrls: photosUrls ?? this.photosUrls,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    createdBy,
    assignedTo,
    status,
    photosUrls,
    createdAt,
    updatedAt,
  ];
}
