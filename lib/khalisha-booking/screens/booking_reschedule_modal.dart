import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:kulatih_mobile/theme/app_colors.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_model.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_service.dart';
import 'package:kulatih_mobile/khalisha-booking/style/text.dart';

class RescheduleModal extends StatefulWidget {
  final Booking booking;

  const RescheduleModal({super.key, required this.booking});

  @override
  State<RescheduleModal> createState() => _RescheduleModalState();
}

class _RescheduleModalState extends State<RescheduleModal> {
  final BookingService _service = BookingService();

  DateTime? _newDate;
  TimeOfDay? _newStart;

  bool _loading = false;

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: widget.booking.startTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (result != null) {
      setState(() => _newDate = result);
    }
  }

  Future<void> _pickStart() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(widget.booking.startTime),
    );
    if (t != null) setState(() => _newStart = t);
  }

  Future<void> _submit() async {
    if (_newDate == null || _newStart == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please select new date & time",
            style: body(14, color: AppColors.textPrimary),
          ),
        ),
      );
      return;
    }

    final newStartTime = DateTime(
      _newDate!.year,
      _newDate!.month,
      _newDate!.day,
      _newStart!.hour,
      _newStart!.minute,
    );

    setState(() => _loading = true);

    final request = context.read<CookieRequest>();

    try {
      await _service.rescheduleBooking(
        request: request,
        id: widget.booking.id,
        newStart: newStartTime,
      );

      if (!mounted) return;

      Navigator.pop(context, false); // JANGAN REFRESH LIST

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Waiting for coach confirmation...",
            style: body(14, color: AppColors.textPrimary),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Reschedule failed: $e",
            style: body(14, color: AppColors.textPrimary),
          ),
        ),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBg,
      title: Text(
        "Reschedule",
        style: heading(18, color: AppColors.textHeading),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: _pickDate,
            child: Text(
              "Pick new date",
              style: body(14, color: AppColors.buttonText),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: _pickStart,
            child: Text(
              "Pick new time",
              style: body(14, color: AppColors.buttonText),
            ),
          ),
          const SizedBox(height: 14),
          if (_loading)
            const CircularProgressIndicator(
              color: AppColors.primary,
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: body(14, color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: _loading ? null : _submit,
          child: Text(
            "Submit",
            style: body(14, color: AppColors.textHeading),
          ),
        ),
      ],
    );
  }
}
