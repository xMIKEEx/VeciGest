import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vecigest/data/services/document_service.dart';
import 'package:vecigest/domain/models/document_model.dart';
import 'package:vecigest/utils/routes.dart';

class DocListPage extends StatefulWidget {
  const DocListPage({Key? key}) : super(key: key);

  @override
  State<DocListPage> createState() => _DocListPageState();
}

class _DocListPageState extends State<DocListPage> {
  final DocumentService _documentService = DocumentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed:
                () => Navigator.pushNamed(context, AppRoutes.uploadDocument),
          ),
        ],
      ),
      body: StreamBuilder<List<DocumentModel>>(
        stream: _documentService.getDocuments(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(child: Text('Error al cargar documentos'));
          }
          final docs = snap.data ?? [];
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final doc = docs[i];
              return ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: Text(doc.name),
                subtitle: Text(
                  DateFormat.yMd().add_Hm().format(doc.uploadedAt),
                ),
                onTap:
                    () => Navigator.pushNamed(
                      ctx,
                      AppRoutes.documentDetail,
                      arguments: doc,
                    ),
              );
            },
          );
        },
      ),
    );
  }
}
