import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:kulatih_mobile/constants/app_colors.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_model.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_service.dart';
import 'package:kulatih_mobile/models/user_provider.dart';
import 'package:kulatih_mobile/khalisha-booking/screens/booking_reschedule_modal.dart';
import 'package:kulatih_mobile/khalisha-booking/widgets/booking_status_badge.dart';
import 'package:kulatih_mobile/khalisha-booking/style/text.dart'; 

class BookingDetailPage extends StatelessWidget {
  final Booking booking;

  const BookingDetailPage({super.key, required this.booking});

  String _fmtDate(DateTime dt) =>
      DateFormat('EEEE, dd MMM yyyy').format(dt);

  String _fmtTime(DateTime dt) => DateFormat('HH:mm').format(dt);

  @override
  Widget build(BuildContext context) {
    final service = BookingService();
    final user = context.watch<UserProvider>();
    final isCoach = user.isCoach;

    final isUpcoming = booking.isUpcoming;
    final isHistory = booking.isHistory;

    return Scaffold(
      backgroundColor: AppColors.indigo,
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
                  Text(
                    isCoach ? "Client Booking" : "Booking Details",
                    style: heading(26, color: AppColors.gold),
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
                    /// PROFILE INFO
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              AssetImage("assets/default_user.png"),
                        ),
                        const SizedBox(width: 18),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCoach ? booking.memberName : booking.coachName,
                              style: heading(22, color: AppColors.textWhite),
                            ),
                            Text(
                              booking.sport,
                              style: body(16, color: AppColors.textLight),
                            ),
                          ],
                        )
                      ],
                    ),

                    const SizedBox(height: 24),
                    BookingStatusBadge(status: booking.status),

                    const SizedBox(height: 24),
                    _title("Schedule"),
                    _infoBox(
                      icon: Icons.calendar_month,
                      title: _fmtDate(booking.startTime),
                      subtitle:
                          "${_fmtTime(booking.startTime)} - ${_fmtTime(booking.endTime)} WIB",
                    ),

                    const SizedBox(height: 20),
                    _title("Location"),
                    _infoBox(
                      icon: Icons.location_on,
                      title: booking.location,
                    ),

                    const SizedBox(height: 20),
                    _title("Booking ID"),
                    _infoBox(
                      icon: Icons.confirmation_number,
                      title: "#${booking.id}",
                    ),

                    const SizedBox(height: 40),

                    /// BUTTON SECTION
                    if (isCoach && isUpcoming) _coachButtons(context, service),
                    if (!isCoach && isUpcoming) _userButtons(context, service),
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

  Widget _title(String t) => Text(
        t,
        style: heading(20, color: AppColors.gold),
      );

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
          Icon(icon, color: AppColors.textLight),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: body(15, color: Colors.white)),
              if (subtitle != null)
                Text(subtitle, style: body(13, color: Colors.white54)),
            ],
          )
        ],
      ),
    );
  }

  // ---------------- USER BUTTONS ----------------
  Widget _userButtons(BuildContext context, BookingService service) {
    if (booking.status == BookingStatus.rescheduled) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        _gold("View Coach", () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Coach profile page is not implemented yet"),
            ),
          );
        }),
        const SizedBox(height: 12),
        _red("Cancel Booking", () async {
          await service.cancelBooking(booking.id);
          Navigator.pop(context);
        }),
        const SizedBox(height: 12),
        _gold("Reschedule", () {
          showDialog(
            context: context,
            builder: (_) => RescheduleModal(booking: booking),
          );
        }),
      ],
    );
  }

  // ---------------- COACH BUTTONS ----------------
  Widget _coachButtons(BuildContext context, BookingService service) {
    if (booking.status == BookingStatus.pending) {
      return Column(
        children: [
          _gold("Confirm", () async {
            await service.confirmBooking(booking.id);
            Navigator.pop(context);
          }),
        ],
      );
    }

    if (booking.status == BookingStatus.rescheduled) {
      return Column(
        children: [
          _dark("Accept Reschedule", () async {
            await service.acceptReschedule(booking.id);
            Navigator.pop(context);
          }),
          const SizedBox(height: 12),
          _red("Reject", () async {
            await service.rejectReschedule(booking.id);
            Navigator.pop(context);
          }),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  // ---------------- HISTORY BUTTONS ----------------
  Widget _historyButtons(BuildContext context) {
    return Column(
      children: [
        _gold("Review Coach", () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Review feature is not implemented yet"),
            ),
          );
        }),
        const SizedBox(height: 12),
        _dark("Book Again", () {}),
      ],
    );
  }

  // -------- BUTTON HELPERS --------
  Widget _gold(String t, VoidCallback a) =>
      _btn(t, AppColors.gold, Colors.black, a);
  Widget _red(String t, VoidCallback a) =>
      _btn(t, Colors.red, Colors.white, a);
  Widget _dark(String t, VoidCallback a) =>
      _btn(t, Colors.grey.shade700, Colors.white, a);

  Widget _btn(String text, Color bg, Color tc, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: body(15, color: tc),
        ),
      ),
    );
  }
}
