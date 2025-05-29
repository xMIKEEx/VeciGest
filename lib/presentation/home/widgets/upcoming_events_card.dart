import 'package:flutter/material.dart';
import 'package:vecigest/data/services/reservation_service.dart';
import 'package:vecigest/domain/models/reservation_model.dart';

class UpcomingEventsCard extends StatefulWidget {
  final bool isAdmin;
  final VoidCallback onAddEvent;

  const UpcomingEventsCard({
    super.key,
    required this.isAdmin,
    required this.onAddEvent,
  });

  @override
  State<UpcomingEventsCard> createState() => _UpcomingEventsCardState();
}

class _UpcomingEventsCardState extends State<UpcomingEventsCard> {
  final _reservationService = ReservationService();
  bool _eventsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.event,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Próximos eventos y reservas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            if (widget.isAdmin)
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: widget.onAddEvent,
                tooltip: 'Añadir evento',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.1),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<Reservation>>(
          stream: _reservationService.getReservations(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final allUpcomingEventsAndReservations =
                snapshot.data
                    ?.where(
                      (r) => r.startTime.isAfter(
                        DateTime.now().subtract(const Duration(days: 1)),
                      ),
                    )
                    .toList() ??
                [];

            if (allUpcomingEventsAndReservations.isEmpty) {
              return _buildEmptyState();
            }

            final eventsToShow =
                _eventsExpanded
                    ? allUpcomingEventsAndReservations
                    : allUpcomingEventsAndReservations.take(3).toList();

            final hasMoreEvents = allUpcomingEventsAndReservations.length > 3;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...eventsToShow.map(
                  (reservation) => _buildReservationListItem(reservation),
                ),

                if (hasMoreEvents) ...[
                  const SizedBox(height: 8),
                  _buildExpandButton(allUpcomingEventsAndReservations.length),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            'No hay eventos ni reservas programados',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationListItem(Reservation reservation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: const Border(left: BorderSide(color: Colors.green, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.resourceName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reservation.formattedRange,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.event_available, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  Widget _buildExpandButton(int totalCount) {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          setState(() {
            _eventsExpanded = !_eventsExpanded;
          });
        },
        icon: Icon(
          _eventsExpanded ? Icons.expand_less : Icons.expand_more,
          size: 20,
        ),
        label: Text(
          _eventsExpanded ? 'Ver menos' : 'Ver ${totalCount - 3} más',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontFamily: 'Inter',
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.1),
          foregroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
