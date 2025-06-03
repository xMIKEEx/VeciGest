import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vecigest/data/services/poll_service.dart';

class NewPollPage extends StatefulWidget {
  const NewPollPage({super.key});

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

  Color _getOptionColor(int index) {
    final colors = [
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
    ];
    return colors[index % colors.length];
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                slivers: [
                  // Modern SliverAppBar with gradient
                  SliverAppBar(
                    expandedHeight: 200,
                    floating: false,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    flexibleSpace: FlexibleSpaceBar(
                      title: const Text(
                        'Nueva Encuesta',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withOpacity(0.8),
                              Colors.purple.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 60,
                              right: -20,
                              child: Icon(
                                Icons.poll,
                                size: 120,
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            Positioned(
                              bottom: 60,
                              left: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Crea una nueva encuesta',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'para la comunidad',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Form content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Question Card
                            Card(
                              elevation: 8,
                              shadowColor: Colors.purple.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.purple.withOpacity(0.1),
                                      Colors.purple.withOpacity(0.05),
                                    ],
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.purple.withOpacity(
                                                0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.help_outline,
                                              color: Colors.purple,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          const Expanded(
                                            child: Text(
                                              'Pregunta de la Encuesta',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      TextFormField(
                                        controller: _questionCtrl,
                                        decoration: InputDecoration(
                                          hintText:
                                              'Escribe tu pregunta aquí...',
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey.withOpacity(
                                                0.3,
                                              ),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.purple,
                                              width: 2,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.all(
                                            20,
                                          ),
                                        ),
                                        maxLines: 3,
                                        validator:
                                            (v) =>
                                                (v == null || v.trim().isEmpty)
                                                    ? 'Introduce una pregunta'
                                                    : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Options Card
                            Card(
                              elevation: 8,
                              shadowColor: Colors.blue.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.blue.withOpacity(0.1),
                                      Colors.blue.withOpacity(0.05),
                                    ],
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withOpacity(
                                                0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.list,
                                              color: Colors.blue,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          const Expanded(
                                            child: Text(
                                              'Opciones de Respuesta',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              'Mín: 2, Máx: 5',
                                              style: TextStyle(
                                                color: Colors.orange[700],
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),

                                      // Option fields
                                      ...List.generate(
                                        _optionCtrls.length,
                                        (i) => Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: _getOptionColor(
                                                    i,
                                                  ).withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${i + 1}',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: _getOptionColor(i),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: TextFormField(
                                                  controller: _optionCtrls[i],
                                                  decoration: InputDecoration(
                                                    hintText: 'Opción ${i + 1}',
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      borderSide:
                                                          BorderSide.none,
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                          borderSide: BorderSide(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                  0.3,
                                                                ),
                                                          ),
                                                        ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                          borderSide: BorderSide(
                                                            color:
                                                                _getOptionColor(
                                                                  i,
                                                                ),
                                                            width: 2,
                                                          ),
                                                        ),
                                                    contentPadding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                          vertical: 16,
                                                        ),
                                                  ),
                                                  validator:
                                                      (v) =>
                                                          (v == null ||
                                                                  v
                                                                      .trim()
                                                                      .isEmpty)
                                                              ? 'Introduce una opción'
                                                              : null,
                                                ),
                                              ),
                                              if (_optionCtrls.length > 2)
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                    left: 8,
                                                  ),
                                                  child: IconButton(
                                                    icon: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.remove,
                                                        color: Colors.red,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    onPressed:
                                                        () => _removeOption(i),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Add option button
                                      if (_optionCtrls.length < 5)
                                        Center(
                                          child: TextButton.icon(
                                            onPressed: _addOption,
                                            icon: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.add,
                                                color: Colors.green,
                                                size: 20,
                                              ),
                                            ),
                                            label: const Text(
                                              'Añadir Opción',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 12,
                                                  ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Create button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 8,
                                  shadowColor: theme.colorScheme.primary
                                      .withOpacity(0.4),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.send, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Crear Encuesta',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
