import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InviteResidentPage extends StatefulWidget {
  const InviteResidentPage({super.key});

  @override
  State<InviteResidentPage> createState() => _InviteResidentPageState();
}

class _InviteResidentPageState extends State<InviteResidentPage> {
  String? _communityId;
  String? _selectedUnitId;
  String? _selectedUnitName;
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _success;

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

  Future<List<QueryDocumentSnapshot>> _fetchUnits() async {
    if (_communityId == null) return [];
    final snapshot =
        await FirebaseFirestore.instance
            .collection('communities')
            .doc(_communityId)
            .collection('units')
            .where('residentEmail', isNull: true)
            .get();
    return snapshot.docs;
  }

  Future<void> _sendInvitation() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });
    try {
      if (_selectedUnitId == null || _emailController.text.trim().isEmpty) {
        setState(() {
          _error = 'Selecciona una unidad y escribe el email.';
          _isLoading = false;
        });
        return;
      }
      // Generar token de invitación (simple, puedes mejorar seguridad)
      final token = DateTime.now().millisecondsSinceEpoch.toString();
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(_communityId)
          .collection('units')
          .doc(_selectedUnitId)
          .update({
            'inviteToken': token,
            'inviteEmail': _emailController.text.trim(),
            'inviteSentAt': DateTime.now(),
          });
      // Aquí deberías enviar el email real con el enlace, pero solo guardamos el token
      setState(() {
        _success =
            'Invitación generada. Token: $token\n(Pendiente: enviar email real)';
      });
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
      appBar: AppBar(title: const Text('Invitar vecino a unidad')),
      body:
          _communityId == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    FutureBuilder<List<QueryDocumentSnapshot>>(
                      future: _fetchUnits(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final units = snapshot.data!;
                        return DropdownButtonFormField<String>(
                          value: _selectedUnitId,
                          items:
                              units.map((doc) {
                                final name = doc['name'] ?? doc.id;
                                return DropdownMenuItem<String>(
                                  value: doc.id,
                                  child: Text(name),
                                );
                              }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedUnitId = val;
                              _selectedUnitName =
                                  units.firstWhere((d) => d.id == val)['name'];
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Unidad disponible',
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email del vecino',
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_error != null) ...[
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 8),
                    ],
                    if (_success != null) ...[
                      Text(
                        _success!,
                        style: const TextStyle(color: Colors.green),
                      ),
                      const SizedBox(height: 8),
                    ],
                    ElevatedButton(
                      onPressed: _isLoading ? null : _sendInvitation,
                      child:
                          _isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Enviar invitación'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        // Lógica para reenviar invitación
                        if (_selectedUnitId != null &&
                            _emailController.text.trim().isNotEmpty) {
                          await _sendInvitation();
                        }
                      },
                      child: const Text('Reenviar invitación'),
                    ),
                  ],
                ),
              ),
    );
  }
}
