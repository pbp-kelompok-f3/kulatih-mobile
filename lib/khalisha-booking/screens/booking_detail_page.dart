import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'package:kulatih_mobile/constants/app_colors.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_model.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_service.dart';
import 'package:kulatih_mobile/models/user_provider.dart';
import 'package:kulatih_mobile/khalisha-booking/screens/booking_reschedule_modal.dart';
import 'package:kulatih_mobile/khalisha-booking/widgets/booking_status_badge.dart';
import 'package:kulatih_mobile/khalisha-booking/style/text.dart';

import 'package:kulatih_mobile/azizah-rating/services/review_api.dart';
import 'package:kulatih_mobile/azizah-rating/screens/review_detail_page.dart';
import 'package:kulatih_mobile/azizah-rating/widgets/review_form_dialog.dart';

const String kBaseUrl = 'http://localhost:8000';

class BookingDetailPage extends StatefulWidget {
  final Booking booking;

  const BookingDetailPage({super.key, required this.booking});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  late final ReviewApi _reviewApi;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final request = context.read<CookieRequest>();
    _reviewApi = ReviewApi(request);
  }

  String _fmtDate(DateTime dt) => DateFormat('EEEE, dd MMM yyyy').format(dt);
  String _fmtTime(DateTime dt) => DateFormat('HH:mm').format(dt);

  @override
  Widget build(BuildContext context) {
    final service = BookingService();
    final request = context.read<CookieRequest>();
    final user = context.watch<UserProvider>();
    final isCoach = user.isCoach;

    final isUpcoming = widget.booking.isUpcoming;
    final isHistory = widget.booking.isHistory;

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
                        ClipOval(
                          child: Image.network(
                            widget.booking.imageUrl != null &&
                                    widget.booking.imageUrl!.isNotEmpty
                                ? '$kBaseUrl/booking/proxy-image/?url=${Uri.encodeComponent(widget.booking.imageUrl!)}'
                                : 'https://via.placeholder.com/80',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade700,
                              alignment: Alignment.center,
                              child: const Icon(Icons.person,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCoach
                                  ? widget.booking.memberName
                                  : widget.booking.coachName,
                              style: heading(22, color: AppColors.textWhite),
                            ),
                            Text(
                              widget.booking.sport,
                              style: body(16, color: AppColors.textLight),
                            ),
                          ],
                        )
                      ],
                    ),

                    const SizedBox(height: 24),
                    BookingStatusBadge(status: widget.booking.status),

                    const SizedBox(height: 24),
                    _title("Schedule"),
                    _infoBox(
                      icon: Icons.calendar_month,
                      title: _fmtDate(widget.booking.startTime),
                      subtitle:
                          "${_fmtTime(widget.booking.startTime)} - ${_fmtTime(widget.booking.endTime)} WIB",
                    ),

                    const SizedBox(height: 20),
                    _title("Location"),
                    _infoBox(
                      icon: Icons.location_on,
                      title: widget.booking.location,
                    ),

                    const SizedBox(height: 20),
                    _title("Booking ID"),
                    _infoBox(
                      icon: Icons.confirmation_number,
                      title: "#${widget.booking.id}",
                    ),

                    const SizedBox(height: 40),

                    /// BUTTON SECTION
                    if (isCoach && isUpcoming) _coachButtons(context, service, request),
                    if (!isCoach && isUpcoming) _userButtons(context, service, request),
                    if (isHistory) _historyButtons(context, isCoach),

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

  // ================= UI HELPERS =================

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

  // ================= USER BUTTONS =================

  Widget _userButtons(
      BuildContext context, BookingService service, CookieRequest request) {
    if (widget.booking.status == BookingStatus.rescheduled) {
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
          await service.cancelBooking(request, widget.booking.id);
          Navigator.pop(context);
        }),
        const SizedBox(height: 12),
        _gold("Reschedule", () {
          showDialog(
            context: context,
            builder: (_) => RescheduleModal(booking: widget.booking),
          );
        }),
      ],
    );
  }

  // ================= COACH BUTTONS =================

  Widget _coachButtons(
      BuildContext context, BookingService service, CookieRequest request) {
    if (widget.booking.status == BookingStatus.pending) {
      return _gold("Confirm", () async {
        await service.confirmBooking(request, widget.booking.id);
        Navigator.pop(context);
      });
    }

    if (widget.booking.status == BookingStatus.rescheduled) {
      return Column(
        children: [
          _dark("Accept Reschedule", () async {
            await service.acceptReschedule(request, widget.booking.id);
            Navigator.pop(context);
          }),
          const SizedBox(height: 12),
          _red("Reject", () async {
            await service.rejectReschedule(request, widget.booking.id);
            Navigator.pop(context);
          }),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  // ================= HISTORY / REVIEW =================

  Widget _historyButtons(BuildContext context, bool isCoach) {
    // Coach ga perlu review
    if (isCoach) {
      return Column(
        children: [
          _dark("Book Again", () {}),
        ],
      );
    }

    // Kalau cancelled, ga bisa review
    if (widget.booking.status == BookingStatus.cancelled) {
      return Column(
        children: [
          _dark("Book Again", () {}),
        ],
      );
    }

    final sessionEnded = widget.booking.endTime.isBefore(DateTime.now());
    final canReview =
        sessionEnded || widget.booking.status == BookingStatus.completed;

    if (!canReview) {
      return Column(
        children: [
          _dark("Book Again", () {}),
        ],
      );
    }

    if (widget.booking.coachId.trim().isEmpty) {
      return Column(
        children: [
          _gold("Leave Review", () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    "Coach ID not found (backend booking belum ngirim coach_id)"),
              ),
            );
          }),
          const SizedBox(height: 12),
          _dark("Book Again", () {}),
        ],
      );
    }

    return FutureBuilder<int?>(
      future: _reviewApi.getMyReviewIdForCoach(coachId: widget.booking.coachId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Column(
            children: [
              _gold("Loading...", () {}),
              const SizedBox(height: 12),
              _dark("Book Again", () {}),
            ],
          );
        }

        final reviewId = snap.data;

        if (reviewId == null) {
          return Column(
            children: [
              _gold("Leave Review", () async {
                final ok = await ReviewFormDialog.showCreate(
                  context,
                  coachId: widget.booking.coachId,
                );
                if (ok == true && context.mounted) {
                  setState(() {});
                }
              }),
              const SizedBox(height: 12),
              _dark("Book Again", () {}),
            ],
          );
        }

        return Column(
          children: [
            _gold("View Your Review", () async {
              final changed = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReviewDetailPage(reviewId: reviewId),
                ),
              );
              if (changed == true && context.mounted) {
                setState(() {});
              }
            }),
            const SizedBox(height: 12),
            _dark("Book Again", () {}),
          ],
        );
      },
    );
  }

  // ================= BUTTON HELPERS =================

  Widget _gold(String t, VoidCallback a) => _btn(t, AppColors.gold, Colors.black, a);
  Widget _red(String t, VoidCallback a) => _btn(t, Colors.red, Colors.white, a);
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
