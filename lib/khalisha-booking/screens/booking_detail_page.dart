import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_model.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_service.dart';
import 'package:kulatih_mobile/khalisha-booking/screens/booking_reschedule_modal.dart';

class BookingDetailPage extends StatelessWidget {
  final Booking booking;

  const BookingDetailPage({super.key, required this.booking});

  String formatDate(DateTime dt) =>
      DateFormat('EEEE, dd MMMM yyyy', 'en').format(dt);

  String formatTime(DateTime dt) =>
      DateFormat('HH:mm').format(dt);

  @override
  Widget build(BuildContext context) {
    const indigo = Color(0xFF0F0F38);
    const gold = Color(0xFFD4BC4E);

    final service = BookingService();

    final isUpcoming = booking.status != BookingStatus.completed &&
        booking.status != BookingStatus.cancelled &&
        booking.startTime.isAfter(DateTime.now());

    return Scaffold(
      backgroundColor: indigo,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            /// HEADER
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
                      color: gold,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ---------------- COACH INFO ----------------
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage("assets/default_user.png"),
                        ),
                        const SizedBox(width: 18),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.coachName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              booking.sport,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),

                    const SizedBox(height: 24),
                    _statusBadge(booking.status),
                    const SizedBox(height: 24),

                    /// ---------------- SCHEDULE ----------------
                    _sectionTitle("Schedule"),
                    _infoBox(
                      icon: Icons.calendar_month,
                      title: formatDate(booking.startTime),
                      subtitle:
                          "${formatTime(booking.startTime)} - ${formatTime(booking.endTime)} WIB",
                    ),

                    const SizedBox(height: 20),

                    /// ---------------- LOCATION ----------------
                    _sectionTitle("Location"),
                    _infoBox(
                      icon: Icons.location_on,
                      title: booking.location,
                    ),

                    const SizedBox(height: 20),

                    /// ---------------- BOOKING ID ----------------
                    _sectionTitle("Booking ID"),
                    _infoBox(
                      icon: Icons.confirmation_number,
                      title: "#${booking.id}",
                    ),

                    const SizedBox(height: 40),

                    /// ---------------- ACTION BUTTONS ----------------
                    isUpcoming
                        ? _upcomingButtons(context, service)
                        : _historyButtons(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ---------------- SECTION TITLE ---------------- */

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFD4BC4E),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /* ---------------- INFO BOX ---------------- */

  Widget _infoBox({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C4A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }

  /* ---------------- STATUS BADGE ---------------- */

  Widget _statusBadge(BookingStatus status) {
    Color c;
    switch (status) {
      case BookingStatus.confirmed:
        c = Colors.green;
        break;
      case BookingStatus.rescheduled:
        c = Colors.purple;
        break;
      case BookingStatus.completed:
        c = Colors.blue;
        break;
      case BookingStatus.cancelled:
        c = Colors.grey;
        break;
      default:
        c = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        bookingStatusToText(status).toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /* ---------------- ACTION BUTTONS ---------------- */

  Widget _upcomingButtons(BuildContext context, BookingService service) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () async {
              await service.cancelBooking(booking.id);
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFD4BC4E),
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => RescheduleModal(booking: booking),
              );
            },
            child: const Text(
              "Reschedule",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _historyButtons() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFD4BC4E),
        minimumSize: const Size(double.infinity, 50),
      ),
      onPressed: () {},
      child: const Text(
        "Book Again",
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
