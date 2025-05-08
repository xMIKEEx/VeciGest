import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vecigest/data/services/poll_service.dart';

class NewPollPage extends StatefulWidget {
  const NewPollPage({Key? key}) : super(key: key);

  @override
  State<NewPollPage> createState() => _NewPollPageState();
}

class _NewPollPageState extends State<NewPollPage> {
  final _formKey = GlobalKey<FormState>();
  final _questionCtrl = TextEditingController();
  final List<TextEditingController> _optionCtrls = [
    TextEditingController(),
    TextEditingController(),
  ];
  final PollService _pollService = PollService();
  bool _loading = false;

  void _addOption() {
    if (_optionCtrls.length < 5) {
      setState(() => _optionCtrls.add(TextEditingController()));
    }
  }

  void _removeOption(int i) {
    if (_optionCtrls.length > 2) {
      setState(() {
        _optionCtrls.removeAt(i);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');
      await _pollService.createPoll(
        _questionCtrl.text.trim(),
        _optionCtrls.map((c) => c.text.trim()).toList(),
        user.uid,
      );
      setState(() => _loading = false);
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    for (final c in _optionCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva encuesta')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _questionCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Pregunta',
                        ),
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Introduce una pregunta'
                                    : null,
                      ),
                      const SizedBox(height: 24),
                      const Text('Opciones (mínimo 2, máximo 5):'),
                      const SizedBox(height: 8),
                      ...List.generate(
                        _optionCtrls.length,
                        (i) => Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _optionCtrls[i],
                                decoration: InputDecoration(
                                  labelText: 'Opción ${i + 1}',
                                ),
                                validator:
                                    (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Introduce una opción'
                                            : null,
                              ),
                            ),
                            if (_optionCtrls.length > 2)
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeOption(i),
                              ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          if (_optionCtrls.length < 5)
                            TextButton.icon(
                              onPressed: _addOption,
                              icon: const Icon(Icons.add),
                              label: const Text('Añadir opción'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Crear encuesta'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
