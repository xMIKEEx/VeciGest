import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vecigest/data/services/reservation_service.dart';
import 'package:vecigest/data/services/user_role_service.dart';
import 'package:vecigest/domain/models/reservation_model.dart';

class ReservationListPage extends StatefulWidget {
  final Function(Widget)? onNavigate;

  const ReservationListPage({super.key, this.onNavigate});

  @override
  State<ReservationListPage> createState() => _ReservationListPageState();
}

class _ReservationListPageState extends State<ReservationListPage> {
  final ReservationService _reservationService = ReservationService();
  final UserRoleService _userRoleService = UserRoleService();

  bool _isAdmin = false;
  String? _communityId;
  bool _isInitialized = false;
  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRole = await _userRoleService.getUserRoleAndCommunity(user.uid);
      setState(() {
        _isAdmin = userRole?['role'] == 'admin';
        _communityId = userRole?['communityId'];
        _isInitialized = true;
      });
    }
  }

  void _navigateToNewReservation() {
    Navigator.of(context).pushNamed('/new-reservation');
  }

  Future<void> _showDeleteConfirmation(Reservation reservation) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar Reserva'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Estás seguro de que quieres eliminar la reserva de "${reservation.resourceName}"?',
                ),
                const SizedBox(height: 12),
                const Text(
                  'Esta acción eliminará permanentemente la reserva.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (result == true) {
      await _deleteReservation(reservation);
    }
  }

  Future<void> _deleteReservation(Reservation reservation) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await _reservationService.deleteReservation(reservation.id);

      // Cerrar indicador de carga
      if (mounted) Navigator.of(context).pop();

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reserva "${reservation.resourceName}" eliminada correctamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Cerrar indicador de carga si está abierto
      if (mounted) Navigator.of(context).pop();

      // Mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar la reserva: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(DateTime start, DateTime end) {
    final now = DateTime.now();
    if (end.isBefore(now)) return Colors.grey;
    if (start.isAfter(now)) return Colors.green;
    return Colors.blue;
  }

  String _getStatusText(DateTime start, DateTime end) {
    final now = DateTime.now();
    if (end.isBefore(now)) return 'Finalizada';
    if (start.isAfter(now)) return 'Próxima';
    return 'En curso';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Main content with padding for floating header
          Padding(
            padding: const EdgeInsets.only(top: 286),
            child: _buildReservationList(),
          ),
          // Floating header
          _buildFloatingHeader(),
        ],
      ),
    );
  }

  Widget _buildFloatingHeader() {
    const greenColor = Color(0xFF4CAF50);

    return Positioned(
      top: 20,
      left: 16,
      right: 16,
      child: SafeArea(
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            height: 188,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  greenColor,
                  greenColor.withOpacity(0.9),
                  const Color(0xFF43A047),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              children: [
                // Elemento decorativo
                Positioned(
                  top: 10,
                  right: -20,
                  child: Icon(
                    Icons.event_available,
                    size: 80,
                    color: Colors.white.withOpacity(0.1),
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
                              'Reservas',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 28,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Gestiona espacios comunitarios',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Botón de crear reserva (solo para admins)
                      if (_isAdmin)
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: _navigateToNewReservation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: greenColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              minimumSize: const Size(0, 34),
                            ),
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 16,
                            ),
                            label: const Text(
                              'Nueva Reserva',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
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
    );
  }

  Widget _buildReservationList() {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    Stream<List<Reservation>> reservationStream;
    if (_communityId != null) {
      reservationStream = _reservationService.getReservationsByCommunity(
        _communityId!,
      );
    } else {
      reservationStream = _reservationService.getReservations();
    }

    return StreamBuilder<List<Reservation>>(
      stream: reservationStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState();
        }

        final reservations = snapshot.data ?? [];

        if (reservations.isEmpty) {
          return _buildEmptyState();
        }
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            itemCount: reservations.length,
            itemBuilder:
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildReservationCard(reservations[index], index),
                ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      itemCount: 6,
      itemBuilder:
          (_, __) => Shimmer.fromColors(
            baseColor: colorScheme.surfaceContainerHighest,
            highlightColor: colorScheme.surface,
            child: Container(
              height: 120,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
    );
  }

  Widget _buildErrorState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error al cargar reservas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta nuevamente más tarde',
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay reservas disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sé el primero en hacer una reserva',
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(Reservation reservation, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(
      reservation.startTime,
      reservation.endTime,
    );
    final statusText = _getStatusText(
      reservation.startTime,
      reservation.endTime,
    );

    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            // TODO: Navigate to reservation detail
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Detalle de reserva: ${reservation.resourceName}',
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.event_available,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reservation.resourceName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botón de eliminar (solo para admins)
                    if (_isAdmin)
                      IconButton(
                        onPressed: () => _showDeleteConfirmation(reservation),
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red,
                        tooltip: 'Eliminar reserva',
                      ),
                    const Icon(
                      Icons.chevron_right,
                      size: 24,
                      color: Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 20, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reservation.formattedRange,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Reservado por: ${reservation.userId}',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
