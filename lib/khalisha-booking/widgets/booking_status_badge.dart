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
        color: _colorFor(status),
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

  // ---------------- STATUS → COLOR ---------------- //
  Color _colorFor(BookingStatus st) {
    switch (st) {
      case BookingStatus.pending:
        return AppColors.statusPending;      // Yellow
      case BookingStatus.confirmed:
        return AppColors.statusConfirmed;    // Green
      case BookingStatus.rescheduled:
        return AppColors.statusRescheduled;  // Purple
      case BookingStatus.completed:
        return AppColors.statusCompleted;    // Blue
      case BookingStatus.cancelled:
        return AppColors.statusCancelled;    // Grey
      default:
        return Colors.orange;
    }
  }
}
