import 'package:flutter/material.dart';
import 'package:vecigest/presentation/reservations/reservation_list_page.dart';

class ReservationsToolButton extends StatelessWidget {
  const ReservationsToolButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.teal.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.pushNamed(context, '/reservations');
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.event_available, size: 48, color: Colors.teal),
            SizedBox(height: 12),
            Text(
              'Reservas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
