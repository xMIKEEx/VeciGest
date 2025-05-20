import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageUnitsPage extends StatefulWidget {
  const ManageUnitsPage({super.key});

  @override
  State<ManageUnitsPage> createState() => _ManageUnitsPageState();
}

class _ManageUnitsPageState extends State<ManageUnitsPage> {
  final TextEditingController _unitNameController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _communityId;

  @override
  void initState() {
    super.initState();
    _fetchCommunityId();
  }

  Future<void> _fetchCommunityId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    setState(() {
      _communityId = doc.data()?['communityId'] as String?;
    });
  }

  Future<void> _addUnit() async {
    if (_communityId == null || _unitNameController.text.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(_communityId)
          .collection('units')
          .add({
            'name': _unitNameController.text.trim(),
            'createdAt': DateTime.now(),
            'active': true,
            'residentEmail': null,
          });
      _unitNameController.clear();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Unidades')),
      body:
          _communityId == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _unitNameController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre de la unidad',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _addUnit,
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text('Añadir'),
                        ),
                      ],
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 24),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('communities')
                                .doc(_communityId)
                                .collection('units')
                                .orderBy('createdAt')
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final docs = snapshot.data!.docs;
                          if (docs.isEmpty) {
                            return const Center(
                              child: Text('No hay unidades aún.'),
                            );
                          }
                          return ListView.builder(
                            itemCount: docs.length,
                            itemBuilder: (context, i) {
                              final data =
                                  docs[i].data() as Map<String, dynamic>;
                              return ListTile(
                                title: Text(data['name'] ?? ''),
                                subtitle:
                                    data['residentEmail'] != null
                                        ? Text(
                                          'Residente: [33m${data['residentEmail']}[0m',
                                        )
                                        : const Text('Sin residente'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (data['residentEmail'] != null)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.logout,
                                          color: Colors.red,
                                        ),
                                        tooltip: 'Liberar unidad',
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection('communities')
                                              .doc(_communityId)
                                              .collection('units')
                                              .doc(docs[i].id)
                                              .update({
                                                'residentEmail': null,
                                                'active': true,
                                              });
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Unidad liberada',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.person_remove,
                                        color: Colors.orange,
                                      ),
                                      tooltip: 'Dar de baja vecino',
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('communities')
                                            .doc(_communityId)
                                            .collection('units')
                                            .doc(docs[i].id)
                                            .update({
                                              'residentEmail': null,
                                              'active': false,
                                            });
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Vecino dado de baja y unidad desactivada',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    if (data['active'] == false)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.refresh,
                                          color: Colors.green,
                                        ),
                                        tooltip: 'Reactivar unidad',
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection('communities')
                                              .doc(_communityId)
                                              .collection('units')
                                              .doc(docs[i].id)
                                              .update({'active': true});
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Unidad reactivada',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

// 7. Mejorar dashboard contextual y acceso rápido a lo esencial según el rol
// Suponiendo que el dashboard principal es home_page.dart, aquí solo agrego un aviso visual del rol y acceso rápido a gestión de unidades si es admin
// Puedes adaptar el widget HomePage según el rol del usuario
