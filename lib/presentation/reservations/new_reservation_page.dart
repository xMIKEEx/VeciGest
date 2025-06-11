import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:vecigest/data/services/reservation_service.dart';
import 'package:vecigest/data/services/user_role_service.dart';
import 'package:vecigest/domain/models/reservation_model.dart';

class TimeSlot {
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  String get displayTime =>
      '${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)}';
}

class NewReservationPage extends StatefulWidget {
  const NewReservationPage({super.key});

  @override
  State<NewReservationPage> createState() => _NewReservationPageState();
}

class _NewReservationPageState extends State<NewReservationPage> {
  final ReservationService _reservationService = ReservationService();
  final UserRoleService _userRoleService = UserRoleService();

  // Step 1: Resource selection
  String? _selectedResource;
  List<String> _availableResources = [];

  // Step 2: Date selection
  DateTime _selectedDate = DateTime.now();

  // Step 3: Time slot selection
  List<TimeSlot> _availableSlots = [];
  List<TimeSlot> _selectedSlots = [];
  List<Reservation> _existingReservations = [];

  String? _communityId;
  bool _loading = true;
  String? _error;
  int _currentStep = 1;

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

  Future<void> _loadAvailableSlots() async {
    if (_selectedResource == null) return;

    setState(() => _loading = true);

    try {
      // Get all reservations for the selected resource
      final snapshot =
          await _reservationService.reservations
              .where('resourceName', isEqualTo: _selectedResource)
              .get();

      // Filter reservations for the selected date locally
      final startOfDay = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );
      final endOfDay = startOfDay.add(const Duration(days: 1));

      _existingReservations =
          snapshot.docs
              .map((doc) => Reservation.fromFirestore(doc))
              .where(
                (reservation) =>
                    reservation.startTime.isBefore(endOfDay) &&
                    reservation.endTime.isAfter(startOfDay),
              )
              .toList();

      // Generate time slots from 9:00 to 21:00 (30-minute intervals)
      _availableSlots = _generateTimeSlots();
      _selectedSlots = [];

      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = 'Error al cargar horarios: ${e.toString()}';
        _loading = false;
      });
    }
  }

  List<TimeSlot> _generateTimeSlots() {
    final slots = <TimeSlot>[];
    const startHour = 9;
    const endHour = 21;

    for (int hour = startHour; hour < endHour; hour++) {
      for (int minute in [0, 30]) {
        final slotStart = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          hour,
          minute,
        );
        final slotEnd = slotStart.add(const Duration(minutes: 30));

        // Check if this slot conflicts with existing reservations
        final isAvailable =
            !_existingReservations.any(
              (reservation) =>
                  (slotStart.isBefore(reservation.endTime) &&
                      slotEnd.isAfter(reservation.startTime)),
            );

        slots.add(
          TimeSlot(
            startTime: slotStart,
            endTime: slotEnd,
            isAvailable: isAvailable,
          ),
        );
      }
    }

    return slots;
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _toggleTimeSlot(TimeSlot slot) {
    if (!slot.isAvailable) return;

    setState(() {
      if (_selectedSlots.contains(slot)) {
        _selectedSlots.remove(slot);
      } else {
        _selectedSlots.add(slot);
      }
      // Sort selected slots by time
      _selectedSlots.sort((a, b) => a.startTime.compareTo(b.startTime));
    });
  }

  Future<void> _submitReservation() async {
    if (_selectedSlots.isEmpty) {
      _showError('Por favor selecciona al menos un horario');
      return;
    }

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      // Create reservation with continuous time slots
      final startTime = _selectedSlots.first.startTime;
      final endTime = _selectedSlots.last.endTime;

      final reservation = Reservation(
        id: '',
        resourceName: _selectedResource!,
        userId: user.uid,
        communityId: _communityId!,
        startTime: startTime,
        endTime: endTime,
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
      setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _nextStep() {
    if (_currentStep == 1 && _selectedResource != null) {
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      _loadAvailableSlots();
      setState(() => _currentStep = 3);
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    const tealColor = Color(0xFF4CAF50);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 98, // Increased by 75% from standard 56px
        title: const Text(
          'Nueva Reserva',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: tealColor,
        foregroundColor: Colors.white, // Ensures back arrow is white
        elevation: 8,
        shadowColor: tealColor.withOpacity(0.3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tealColor,
                tealColor.withOpacity(0.9),
                const Color(0xFF43A047),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildErrorWidget()
              : _availableResources.isEmpty
              ? _buildNoResourcesWidget()
              : _buildStepContent(),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildResourceSelection();
      case 2:
        return _buildDateSelection();
      case 3:
        return _buildTimeSlotSelection();
      default:
        return _buildResourceSelection();
    }
  }

  Widget _buildResourceSelection() {
    const tealColor = Color(0xFF4CAF50);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          const SizedBox(height: 24),

          // Resource selection card
          Card(
            elevation: 8,
            shadowColor: tealColor.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tealColor.withOpacity(0.1),
                    tealColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: tealColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.event_available,
                          color: tealColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Seleccionar Recurso',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(_availableResources.length, (index) {
                    final resource = _availableResources[index];
                    final isSelected = _selectedResource == resource;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedResource = resource;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? tealColor.withOpacity(0.1)
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? tealColor
                                        : Colors.grey.withOpacity(0.3),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  color: isSelected ? tealColor : Colors.grey,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    resource,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                      color:
                                          isSelected
                                              ? tealColor
                                              : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Next button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _selectedResource != null ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: tealColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: tealColor.withOpacity(0.3),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_forward, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Continuar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    const tealColor = Color(0xFF4CAF50);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          const SizedBox(height: 24),

          // Date selection card
          Card(
            elevation: 8,
            shadowColor: tealColor.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tealColor.withOpacity(0.1),
                    tealColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: tealColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.calendar_today,
                          color: tealColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Seleccionar Fecha',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.calendar_month),
                      label: Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: tealColor, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _previousStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back, size: 20),
                      SizedBox(width: 8),
                      Text('Anterior'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tealColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_forward, size: 20),
                      SizedBox(width: 8),
                      Text('Continuar'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotSelection() {
    const tealColor = Color(0xFF4CAF50);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          const SizedBox(height: 24),

          // Time slots card
          Card(
            elevation: 8,
            shadowColor: tealColor.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tealColor.withOpacity(0.1),
                    tealColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: tealColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.access_time,
                          color: tealColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Horarios Disponibles',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              DateFormat('dd/MM/yyyy').format(_selectedDate),
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Time slots grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _availableSlots.length,
                    itemBuilder: (context, index) {
                      final slot = _availableSlots[index];
                      final isSelected = _selectedSlots.contains(slot);

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _toggleTimeSlot(slot),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  !slot.isAvailable
                                      ? Colors.grey.withOpacity(0.2)
                                      : isSelected
                                      ? tealColor
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    !slot.isAvailable
                                        ? Colors.grey.withOpacity(0.5)
                                        : isSelected
                                        ? tealColor
                                        : tealColor.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                slot.displayTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      !slot.isAvailable
                                          ? Colors.grey
                                          : isSelected
                                          ? Colors.white
                                          : tealColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  if (_selectedSlots.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: tealColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: tealColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resumen de la reserva:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: tealColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Recurso: $_selectedResource',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Horario: ${_selectedSlots.first.displayTime.split(' - ')[0]} - ${_selectedSlots.last.displayTime.split(' - ')[1]}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _previousStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back, size: 20),
                      SizedBox(width: 8),
                      Text('Anterior'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      _selectedSlots.isNotEmpty ? _submitReservation : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tealColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, size: 20),
                      SizedBox(width: 8),
                      Text('Crear Reserva'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    const tealColor = Color(0xFF4CAF50);

    return Row(
      children: [
        _buildProgressStep(1, 'Recurso', _currentStep >= 1),
        Expanded(
          child: Container(
            height: 2,
            color: _currentStep >= 2 ? tealColor : Colors.grey.withOpacity(0.3),
          ),
        ),
        _buildProgressStep(2, 'Fecha', _currentStep >= 2),
        Expanded(
          child: Container(
            height: 2,
            color: _currentStep >= 3 ? tealColor : Colors.grey.withOpacity(0.3),
          ),
        ),
        _buildProgressStep(3, 'Horario', _currentStep >= 3),
      ],
    );
  }

  Widget _buildProgressStep(int step, String label, bool isActive) {
    const tealColor = Color(0xFF4CAF50);

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? tealColor : Colors.grey.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? tealColor : Colors.grey,
          ),
        ),
      ],
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
}
