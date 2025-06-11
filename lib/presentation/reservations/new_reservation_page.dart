import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vecigest/data/services/reservation_service.dart';
import 'package:vecigest/data/services/user_role_service.dart';
import 'package:vecigest/domain/models/reservation_model.dart';

class NewReservationPage extends StatefulWidget {
  const NewReservationPage({super.key});

  @override
  State<NewReservationPage> createState() => _NewReservationPageState();
}

class _NewReservationPageState extends State<NewReservationPage> {
  final _formKey = GlobalKey<FormState>();
  final ReservationService _reservationService = ReservationService();
  final UserRoleService _userRoleService = UserRoleService();

  String? _selectedResource;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  List<String> _availableResources = [];
  String? _communityId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAvailableResources();
  }

  Future<void> _loadAvailableResources() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userRole = await _userRoleService.getUserRoleAndCommunity(
          user.uid,
        );
        _communityId = userRole?['communityId'];

        if (_communityId != null) {
          final resources = await _reservationService.getAvailableResources(
            _communityId!,
          );
          setState(() {
            _availableResources = resources;
            _loading = false;
          });
        } else {
          setState(() {
            _error = 'No se pudo obtener la comunidad del usuario';
            _loading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Error al cargar recursos: ${e.toString()}';
        _loading = false;
      });
    }
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _startTime = time;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _endTime = time;
      });
    }
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedResource == null) {
      _showError('Por favor selecciona un recurso');
      return;
    }

    if (_startDate == null ||
        _startTime == null ||
        _endDate == null ||
        _endTime == null) {
      _showError('Por favor selecciona fecha y hora de inicio y fin');
      return;
    }

    final startDateTime = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final endDateTime = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      _showError('La fecha de fin debe ser posterior a la fecha de inicio');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final reservation = Reservation(
        id: '', // Firestore auto-genera el ID
        resourceName: _selectedResource!,
        userId: user.uid,
        communityId: _communityId!,
        startTime: startDateTime,
        endTime: endDateTime,
      );

      await _reservationService.addReservation(reservation);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Error al crear la reserva: ${e.toString()}');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Reserva'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildErrorWidget()
              : _availableResources.isEmpty
              ? _buildNoResourcesWidget()
              : _buildForm(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAvailableResources,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResourcesWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_busy, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No hay recursos disponibles',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Contacta con tu administrador para que configure los recursos reservables',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Selector de recurso
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seleccionar Recurso',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedResource,
                    decoration: const InputDecoration(
                      labelText: 'Recurso',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        _availableResources.map((resource) {
                          return DropdownMenuItem(
                            value: resource,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.event_available,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(resource),
                              ],
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedResource = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor selecciona un recurso';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Fecha y hora de inicio
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha y Hora de Inicio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectStartDate,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _startDate != null
                                ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                : 'Seleccionar fecha',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectStartTime,
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            _startTime != null
                                ? _startTime!.format(context)
                                : 'Seleccionar hora',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Fecha y hora de fin
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha y Hora de Fin',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectEndDate,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _endDate != null
                                ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                : 'Seleccionar fecha',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectEndTime,
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            _endTime != null
                                ? _endTime!.format(context)
                                : 'Seleccionar hora',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Botón de crear reserva
          ElevatedButton(
            onPressed: _loading ? null : _submitReservation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              _loading ? 'Creando...' : 'Crear Reserva',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
