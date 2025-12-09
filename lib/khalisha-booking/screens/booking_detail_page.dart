import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kulatih_mobile/constants/app_colors.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_model.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_service.dart';
import 'package:kulatih_mobile/khalisha-booking/screens/booking_reschedule_modal.dart';
import 'package:kulatih_mobile/khalisha-booking/widgets/booking_status_badge.dart';

class BookingDetailPage extends StatelessWidget {
  final Booking booking;

  const BookingDetailPage({super.key, required this.booking});

  String _formatDate(DateTime dt) =>
      DateFormat('EEEE, dd MMMM yyyy', 'en').format(dt);

  String _formatTime(DateTime dt) => DateFormat('HH:mm').format(dt);

  @override
  Widget build(BuildContext context) {
    final service = BookingService();

    final isUpcoming = booking.isUpcoming;
    final isHistory = booking.isHistory;

    return Scaffold(
      backgroundColor: AppColors.indigo,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Booking Details",
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // COACH INFO
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: booking.imageUrl != null
                              ? NetworkImage(booking.imageUrl!)
                              : const AssetImage("assets/default_user.png")
                                  as ImageProvider,
                        ),
                        const SizedBox(width: 18),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.coachName,
                              style: const TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              booking.sport,
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),

                    const SizedBox(height: 24),
                    BookingStatusBadge(status: booking.status),
                    const SizedBox(height: 24),

                    // SCHEDULE
                    _title("Schedule"),
                    _infoBox(
                      icon: Icons.calendar_month,
                      title: _formatDate(booking.startTime),
                      subtitle:
                          "${_formatTime(booking.startTime)} - ${_formatTime(booking.endTime)} WIB",
                    ),

                    const SizedBox(height: 20),

                    // LOCATION
                    _title("Location"),
                    _infoBox(
                      icon: Icons.location_on,
                      title: booking.location,
                    ),

                    const SizedBox(height: 20),

                    // BOOKING ID
                    _title("Booking ID"),
                    _infoBox(
                      icon: Icons.confirmation_number,
                      title: "#${booking.id}",
                    ),

                    const SizedBox(height: 40),

                    // BUTTONS SECTION
                    if (isUpcoming) _upcomingButtons(context, service),

                    if (isHistory) _historyButtons(context),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI HELPERS ------------------------------------------------------------

  Widget _title(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.gold,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _infoBox({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textLight, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: AppColors.textWhite, fontSize: 16)),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }

  // UPCOMING BUTTONS (Cancel + Reschedule + View Coach)
  Widget _upcomingButtons(BuildContext context, BookingService service) {
    return Column(
      children: [
        _goldButton(
          "View Coach",
          () {
            Navigator.pushNamed(
              context,
              "/coach/detail",
              arguments: {
                "coachName": booking.coachName,
                "coachId": booking.id, // ganti kalau backend beda
              },
            );
          },
        ),
        const SizedBox(height: 12),

        // Cancel
        _redButton(
          "Cancel Booking",
          () async {
            await service.cancelBooking(booking.id);
            Navigator.pop(context);
          },
        ),
        const SizedBox(height: 12),

        // Reschedule
        _goldButton(
          "Reschedule",
          () => showDialog(
            context: context,
            builder: (_) => RescheduleModal(booking: booking),
          ),
        ),
      ],
    );
  }

  // HISTORY BUTTONS (Review + Book Again + View Coach)
  Widget _historyButtons(BuildContext context) {
    return Column(
      children: [
        _goldButton(
          "View Coach",
          () {
            Navigator.pushNamed(
              context,
              "/coach/detail",
              arguments: {
                "coachName": booking.coachName,
                "coachId": booking.id,
              },
            );
          },
        ),
        const SizedBox(height: 12),

        if (booking.status == BookingStatus.completed)
          _darkButton(
            "View Your Review",
            () {
              Navigator.pushNamed(
                context,
                "/coach/review",
                arguments: booking.id,
              );
            },
          ),

        const SizedBox(height: 12),

        _darkButton(
          "Book Again",
          () {
            Navigator.pushNamed(
              context,
              "/booking/create",
              arguments: {"coachId": booking.id},
            );
          },
        ),
      ],
    );
  }

  // BUTTON COMPONENTS -----------------------------------------------------

  Widget _goldButton(String text, VoidCallback onTap) => _btn(
        text: text,
        bg: AppColors.gold,
        textColor: Colors.black,
        onTap: onTap,
      );

  Widget _redButton(String text, VoidCallback onTap) => _btn(
        text: text,
        bg: Colors.red,
        onTap: onTap,
      );

  Widget _darkButton(String text, VoidCallback onTap) => _btn(
        text: text,
        bg: Colors.grey.shade700,
        onTap: onTap,
      );

  Widget _btn({
    required String text,
    required Color bg,
    Color textColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          text,
          style: TextStyle(
              color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
