import 'package:flutter/material.dart';
import 'package:vecigest/domain/models/document_model.dart';

class DocumentDetailPage extends StatelessWidget {
  final DocumentModel document;

  const DocumentDetailPage({Key? key, required this.document})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(document.name)),
      body: Center(child: Text('Details for ${document.name}')),
    );
  }
}
