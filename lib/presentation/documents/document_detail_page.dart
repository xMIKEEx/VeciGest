import 'package:flutter/material.dart';
import 'package:vecigest/domain/models/document_model.dart';

class DocumentDetailPage extends StatelessWidget {
  final DocumentModel document;

  const DocumentDetailPage({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(document.name)),
      body: Center(child: Text('Details for ${document.name}')),
    );
  }
}
