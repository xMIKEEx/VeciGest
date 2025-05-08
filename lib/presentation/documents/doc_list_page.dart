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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.background,
      child: StreamBuilder<List<DocumentModel>>(
        stream: _documentService.getDocuments(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(child: Text('Error al cargar documentos'));
          }
          final docs = snap.data ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No hay documentos disponibles',
                style: TextStyle(
                  color: colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final doc = docs[i];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  leading: const Icon(Icons.insert_drive_file, size: 32),
                  title: Text(
                    doc.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat.yMd().add_Hm().format(doc.uploadedAt),
                      style: TextStyle(
                        color: colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 28),
                  onTap:
                      () => Navigator.pushNamed(
                        ctx,
                        AppRoutes.documentDetail,
                        arguments: doc,
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
