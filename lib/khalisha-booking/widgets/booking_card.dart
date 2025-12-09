import 'package:flutter/material.dart';
import 'package:kulatih_mobile/constants/app_colors.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_model.dart';
import 'package:kulatih_mobile/khalisha-booking/widgets/booking_status_badge.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final bool historyMode;

  final VoidCallback onCancel;
  final VoidCallback onReschedule;

  // History extras
  final VoidCallback? onBookAgain;
  final VoidCallback? onViewReview;

  const BookingCard({
    super.key,
    required this.booking,
    required this.historyMode,
    required this.onCancel,
    required this.onReschedule,
    this.onBookAgain,
    this.onViewReview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// DATE + STATUS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.formattedDateTime,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                ),
              ),
              BookingStatusBadge(status: booking.status),
            ],
          ),

          const SizedBox(height: 12),

          /// COACH ROW
          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundImage: AssetImage("assets/default_user.png"),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.coachName,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    booking.sport,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// LOCATION
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: AppColors.textLight,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                booking.location,
                style: const TextStyle(color: AppColors.textLight),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),

          historyMode ? _historyButtons() : _upcomingButtons(),
        ],
      ),
    );
  }

  /// UPCOMING BUTTONS (NO VIEW DETAILS)
  Widget _upcomingButtons() {
    return Row(
      children: [
        _btn("Cancel", Colors.red, onCancel),
        _btn("Reschedule", Colors.grey, onReschedule),
      ],
    );
  }

  /// HISTORY BUTTONS
  Widget _historyButtons() {
    return Row(
      children: [
        _btn("View Review", AppColors.gold, onViewReview ?? () {}),
        _btn("Book Again", Colors.grey.shade700, onBookAgain ?? () {}),
      ],
    );
  }

  Widget _btn(String text, Color bg, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
