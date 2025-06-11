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
      Colors.purple.shade600, // Primary purple
      Colors.purple.shade400, // Lighter purple
      Colors.purple.shade800, // Darker purple
      Colors.deepPurple.shade600, // Deep purple variant
      Colors.purple.shade300, // Very light purple
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
      extendBodyBehindAppBar: true,
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  // Main content with padding for floating header
                  Padding(
                    padding: const EdgeInsets.only(top: 220),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      child: _buildForm(theme),
                    ),
                  ),
                  // Floating header
                  _buildFloatingHeader(),
                ],
              ),
    );
  }

  Widget _buildFloatingHeader() {
    const purpleColor = Color(0xFF9C27B0);

    return Positioned(
      top: 0,
      left: 16,
      right: 16,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 16),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    purpleColor,
                    purpleColor.withOpacity(0.9),
                    const Color(0xFF7B1FA2),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: purpleColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Elemento decorativo
                  Positioned(
                    top: 10,
                    right: -10,
                    child: Icon(
                      Icons.poll,
                      size: 80,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  // Back button
                  Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  // Contenido principal
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Nueva Encuesta',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 28,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Crea una encuesta para la comunidad',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionCard(theme),
          const SizedBox(height: 20),
          _buildOptionsCard(theme),
          const SizedBox(height: 24),
          _buildCreateButton(theme),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(ThemeData theme) {
    const purpleColor = Color(0xFF9C27B0);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: purpleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.help_outline, color: purpleColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Pregunta de la Encuesta',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _questionCtrl,
              decoration: InputDecoration(
                labelText: 'Pregunta *',
                hintText: 'Ej: ¿Estás de acuerdo con la nueva normativa?',
                prefixIcon: Icon(Icons.quiz, color: purpleColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: purpleColor, width: 2),
                ),
                labelStyle: TextStyle(color: purpleColor),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Introduce una pregunta';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsCard(ThemeData theme) {
    const purpleColor = Color(0xFF9C27B0);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: purpleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.list, color: purpleColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Opciones de Respuesta',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Mínimo 2, máximo 5 opciones',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: purpleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_optionCtrls.length} opciones',
                    style: TextStyle(
                      color: purpleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...List.generate(
              _optionCtrls.length,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _optionCtrls[i],
                        decoration: InputDecoration(
                          labelText: 'Opción ${i + 1} *',
                          hintText: 'Escribe una opción de respuesta',
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _getOptionColor(i).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.radio_button_checked,
                              color: _getOptionColor(i),
                              size: 16,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: purpleColor,
                              width: 2,
                            ),
                          ),
                          labelStyle: TextStyle(color: purpleColor),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Introduce una opción';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (_optionCtrls.length > 2)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: IconButton(
                          icon: Icon(
                            Icons.remove_circle,
                            color: Colors.red.withOpacity(0.7),
                          ),
                          onPressed: () => _removeOption(i),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (_optionCtrls.length < 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton.icon(
                  onPressed: _addOption,
                  icon: Icon(Icons.add, color: purpleColor),
                  label: Text(
                    'Añadir opción',
                    style: TextStyle(color: purpleColor),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton(ThemeData theme) {
    const purpleColor = Color(0xFF9C27B0);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _loading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: purpleColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        icon:
            _loading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : const Icon(Icons.poll, size: 20),
        label: Text(
          _loading ? 'Creando...' : 'Crear Encuesta',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
