import 'package:flutter/material.dart';
import 'package:kulatih_mobile/constants/app_colors.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_model.dart';

class BookingStatusBadge extends StatelessWidget {
  final BookingStatus status;

  const BookingStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _mapStatusColor(status),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        bookingStatusToText(status).toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _mapStatusColor(BookingStatus st) {
    switch (st) {
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.rescheduled:
        return Colors.purple;
      case BookingStatus.completed:
        return Colors.blue;
      case BookingStatus.cancelled:
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }
}
