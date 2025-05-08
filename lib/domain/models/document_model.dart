import 'package:equatable/equatable.dart';

class DocumentModel extends Equatable {
  final String id;
  final String name;
  final String url;
  final String folder;
  final String uploaderId;
  final DateTime uploadedAt;

  const DocumentModel({
    required this.id,
    required this.name,
    required this.url,
    required this.folder,
    required this.uploaderId,
    required this.uploadedAt,
  });

  factory DocumentModel.fromMap(Map<String, dynamic> map, String id) {
    return DocumentModel(
      id: id,
      name: map['name'] as String,
      url: map['url'] as String,
      folder: map['folder'] as String,
      uploaderId: map['uploaderId'] as String,
      uploadedAt:
          (map['uploadedAt'] is DateTime)
              ? map['uploadedAt'] as DateTime
              : (map['uploadedAt'] != null && map['uploadedAt'].toDate != null)
              ? map['uploadedAt'].toDate() as DateTime
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
      'folder': folder,
      'uploaderId': uploaderId,
      'uploadedAt': uploadedAt,
    };
  }

  DocumentModel copyWith({
    String? name,
    String? url,
    String? folder,
    DateTime? uploadedAt,
  }) {
    return DocumentModel(
      id: id,
      name: name ?? this.name,
      url: url ?? this.url,
      folder: folder ?? this.folder,
      uploaderId: uploaderId,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, url, folder, uploaderId, uploadedAt];
}
