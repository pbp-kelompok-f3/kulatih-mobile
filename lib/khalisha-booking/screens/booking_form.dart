import 'package:flutter/material.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_model.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_service.dart';

class BookingFormPage extends StatefulWidget {
  final bool isReschedule;
  final Booking? initialBooking;

  const BookingFormPage({
    super.key,
    this.isReschedule = false,
    this.initialBooking,
  });

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final BookingService _service = BookingService();

  int? coachId;
  String? location;

  DateTime? date;
  TimeOfDay? start;
  TimeOfDay? end;

  bool _loading = false;

  // Pre-fill jika reschedule
  @override
  void initState() {
    super.initState();
    if (widget.isReschedule && widget.initialBooking != null) {
      final b = widget.initialBooking!;
      coachId = 99; // coach ID sementara (API kamu belum include coach_id)
      location = b.location;
      date = b.startTime;
      start = TimeOfDay.fromDateTime(b.startTime);
      end = TimeOfDay.fromDateTime(b.endTime);
    }
  }

  Future<void> _pickDate() async {
    final res = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (res != null) setState(() => date = res);
  }

  Future<void> _pickStart() async {
    final res = await showTimePicker(
      context: context,
      initialTime: start ?? TimeOfDay.now(),
    );
    if (res != null) setState(() => start = res);
  }

  Future<void> _pickEnd() async {
    final res = await showTimePicker(
      context: context,
      initialTime: end ?? TimeOfDay.now(),
    );
    if (res != null) setState(() => end = res);
  }

  Future<void> _submit() async {
    if (date == null || start == null || end == null || location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final DateTime finalDT = DateTime(
      date!.year,
      date!.month,
      date!.day,
      start!.hour,
      start!.minute,
    );

    setState(() => _loading = true);

    try {
      if (widget.isReschedule) {
        await _service.rescheduleBooking(
          bookingId: widget.initialBooking!.id,
          newDate: finalDT,
        );
      } else {
        await _service.createBooking(
          coachId: coachId ?? 1, // default sementara
          location: location!,
          startTime: finalDT,
        );
      }

      if (context.mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F2A),
        elevation: 0,
        title: Text(
          widget.isReschedule ? "Reschedule Booking" : "New Booking",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // LOCATION
          TextField(
            onChanged: (v) => location = v,
            controller: widget.isReschedule
                ? TextEditingController(text: widget.initialBooking!.location)
                : null,
            decoration: _input("Location"),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),

          // DATE
          _pickerTile(
            label: date == null
                ? "Select Date"
                : "${date!.day}/${date!.month}/${date!.year}",
            onTap: _pickDate,
          ),
          const SizedBox(height: 16),

          // START TIME
          _pickerTile(
            label: start == null
                ? "Start Time"
                : "${start!.hour.toString().padLeft(2, '0')}:${start!.minute.toString().padLeft(2, '0')}",
            onTap: _pickStart,
          ),
          const SizedBox(height: 16),

          // END TIME
          _pickerTile(
            label: end == null
                ? "End Time"
                : "${end!.hour.toString().padLeft(2, '0')}:${end!.minute.toString().padLeft(2, '0')}",
            onTap: _pickEnd,
          ),
          const SizedBox(height: 32),

          _loading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD3B53E),
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: _submit,
                  child: Text(widget.isReschedule ? "Reschedule" : "Book Now"),
                ),
        ],
      ),
    );
  }

  InputDecoration _input(String title) {
    return InputDecoration(
      labelText: title,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white30),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _pickerTile({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C3A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
