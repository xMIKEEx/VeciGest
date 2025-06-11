import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vecigest/data/services/reservation_service.dart';
import 'package:vecigest/data/services/user_role_service.dart';
import 'package:vecigest/domain/models/reservation_model.dart';

class NewEventPage extends StatefulWidget {
  final VoidCallback? onClose;

  const NewEventPage({super.key, this.onClose});

  @override
  State<NewEventPage> createState() => _NewEventPageState();
}

class _NewEventPageState extends State<NewEventPage> {
  final _formKey = GlobalKey<FormState>();
  final UserRoleService _userRoleService = UserRoleService();
  String eventName = '';
  String description = '';
  DateTime? startDate;
  TimeOfDay? startTime;
  DateTime? endDate;
  TimeOfDay? endTime;
  String? _communityId;

  String? errorMsg;
  bool _isLoading = false;

  Future<void> _pickDateTime({required bool isStart}) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    setState(() {
      if (isStart) {
        startDate = pickedDate;
        startTime = pickedTime;
      } else {
        endDate = pickedDate;
        endTime = pickedTime;
      }
    });
  }

  DateTime? get _startDateTime {
    if (startDate == null || startTime == null) return null;
    return DateTime(
      startDate!.year,
      startDate!.month,
      startDate!.day,
      startTime!.hour,
      startTime!.minute,
    );
  }

  DateTime? get _endDateTime {
    if (endDate == null || endTime == null) return null;
    return DateTime(
      endDate!.year,
      endDate!.month,
      endDate!.day,
      endTime!.hour,
      endTime!.minute,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate() ||
        _startDateTime == null ||
        _endDateTime == null) {
      return;
    }

    _formKey.currentState!.save();

    if (_endDateTime!.isBefore(_startDateTime!)) {
      setState(() {
        errorMsg = 'La fecha/hora de fin debe ser posterior a la de inicio.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      errorMsg = null;
    });

    try {
      // Obtener la comunidad del usuario actual
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final userRole = await _userRoleService.getUserRoleAndCommunity(user.uid);
      _communityId = userRole?['communityId'];

      if (_communityId == null) {
        throw Exception('No se pudo obtener la comunidad del usuario');
      }

      // Creamos el evento como una reserva especial (los eventos son un tipo de reserva)
      final event = Reservation(
        id: '',
        resourceName: eventName,
        userId: "admin", // Los eventos son creados por administradores
        communityId: _communityId!,
        startTime: _startDateTime!,
        endTime: _endDateTime!,
      );

      await ReservationService().addReservation(event);

      if (mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evento creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Navegar hacia atrás
        if (widget.onClose != null) {
          widget.onClose!();
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMsg = 'Error al crear el evento: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Evento'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (widget.onClose != null) {
              widget.onClose!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Icono y título
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.event,
                        size: 48,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Crear Nuevo Evento',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Los eventos aparecerán en la página principal para todos los usuarios',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Nombre del evento
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nombre del evento',
                  hintText: 'Ej: Reunión de vecinos, Fiesta de verano...',
                  prefixIcon: Icon(Icons.event),
                  border: OutlineInputBorder(),
                ),
                onSaved: (v) => eventName = v ?? '',
                validator:
                    (v) =>
                        v == null || v.isEmpty
                            ? 'El nombre es obligatorio'
                            : null,
              ),

              const SizedBox(height: 16),

              // Descripción (opcional)
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  hintText: 'Describe los detalles del evento...',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (v) => description = v ?? '',
              ),

              const SizedBox(height: 24),

              // Fechas y horas
              Text(
                'Fecha y Hora',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Fecha/hora inicio
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _startDateTime == null
                      ? 'Seleccionar fecha/hora de inicio'
                      : 'Inicio: ${_formatDateTime(_startDateTime!)}',
                ),
                onPressed: () => _pickDateTime(isStart: true),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft,
                ),
              ),

              const SizedBox(height: 12),

              // Fecha/hora fin
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _endDateTime == null
                      ? 'Seleccionar fecha/hora de fin'
                      : 'Fin: ${_formatDateTime(_endDateTime!)}',
                ),
                onPressed: () => _pickDateTime(isStart: false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft,
                ),
              ),

              const SizedBox(height: 24),

              // Mensaje de error
              if (errorMsg != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMsg!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),

              if (errorMsg != null) const SizedBox(height: 16),

              // Botón guardar
              ElevatedButton.icon(
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Icon(Icons.save),
                label: Text(_isLoading ? 'Creando evento...' : 'Crear Evento'),
                onPressed: _isLoading ? null : _saveEvent,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
