import 'package:flutter/material.dart';
import 'package:vecigest/data/services/reservation_service.dart';
import 'package:vecigest/domain/models/reservation_model.dart';

class ReservationListPage extends StatelessWidget {
  const ReservationListPage({super.key});

  Color _getCardColor(DateTime start, DateTime end) {
    final now = DateTime.now();
    if (end.isBefore(now)) return Colors.grey.shade200;
    if (start.isAfter(now)) return Colors.green.shade50;
    return Colors.blue.shade50;
  }

  @override
  Widget build(BuildContext context) {
    final service = ReservationService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservas'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<Reservation>>(
        stream: service.getReservations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay reservas.'));
          }
          final reservas = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: reservas.length,
            itemBuilder: (context, i) {
              final r = reservas[i];
              return Card(
                color: _getCardColor(r.startTime, r.endTime),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.event_available,
                    color: Colors.teal,
                    size: 36,
                  ),
                  title: Text(
                    r.resourceName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.formattedRange,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Usuario: ${r.userId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueGrey),
                        onPressed: () {
                          // Implementar edición si se desea
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          await service.deleteReservation(r.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NewReservationPage()),
            ),
        icon: const Icon(Icons.add),
        label: const Text('Nueva reserva'),
        backgroundColor: Colors.teal,
      ),
    );
  }
}

class NewReservationPage extends StatefulWidget {
  const NewReservationPage({super.key});

  @override
  State<NewReservationPage> createState() => _NewReservationPageState();
}

class _NewReservationPageState extends State<NewReservationPage> {
  final _formKey = GlobalKey<FormState>();
  String resourceName = '';
  DateTime? startDate;
  TimeOfDay? startTime;
  DateTime? endDate;
  TimeOfDay? endTime;

  String? errorMsg;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Reserva'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Recurso a reservar',
                ),
                onSaved: (v) => resourceName = v ?? '',
                validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _startDateTime == null
                            ? 'Fecha/hora inicio'
                            : Reservation(
                              id: '',
                              resourceName: resourceName,
                              userId: '',
                              startTime: _startDateTime!,
                              endTime: _startDateTime!,
                            ).formattedRange.split(' - ')[0],
                      ),
                      onPressed: () => _pickDateTime(isStart: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _endDateTime == null
                            ? 'Fecha/hora fin'
                            : Reservation(
                              id: '',
                              resourceName: resourceName,
                              userId: '',
                              startTime: _endDateTime!,
                              endTime: _endDateTime!,
                            ).formattedRange.split(' - ')[1],
                      ),
                      onPressed: () => _pickDateTime(isStart: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (errorMsg != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    errorMsg!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      _startDateTime != null &&
                      _endDateTime != null) {
                    _formKey.currentState!.save();
                    if (_endDateTime!.isBefore(_startDateTime!)) {
                      setState(
                        () =>
                            errorMsg =
                                'La fecha/hora de fin debe ser posterior a la de inicio.',
                      );
                      return;
                    }
                    final userId = "demoUser"; // Reemplaza por el usuario real
                    final reserva = Reservation(
                      id: '',
                      resourceName: resourceName,
                      userId: userId,
                      startTime: _startDateTime!,
                      endTime: _endDateTime!,
                    );
                    await ReservationService().addReservation(reserva);
                    if (mounted) Navigator.pop(context);
                  }
                },
                label: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
