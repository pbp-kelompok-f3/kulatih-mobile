import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_model.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_service.dart';

class BookingFormPage extends StatefulWidget {
  final bool isReschedule;
  final Booking? initialBooking;

  const BookingFormPage({
    super.key,
    required this.isReschedule,
    this.initialBooking,
  });

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  bool _isLoading = false;
  final BookingService _service = BookingService();

  @override
  void initState() {
    super.initState();

    // PREFILL for reschedule
    if (widget.isReschedule && widget.initialBooking != null) {
      final b = widget.initialBooking!;
      _locationController.text = b.location;
      _selectedDate = DateTime(
        b.startTime.year,
        b.startTime.month,
        b.startTime.day,
      );
      _startTime = TimeOfDay.fromDateTime(b.startTime);
      _endTime = TimeOfDay.fromDateTime(b.endTime);
    }
  }

  // ======================= PICKERS =======================

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: _selectedDate ?? DateTime.now(),
    );

    if (result != null) setState(() => _selectedDate = result);
  }

  Future<void> _pickStartTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (t != null) setState(() => _startTime = t);
  }

  Future<void> _pickEndTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (t != null) setState(() => _endTime = t);
  }

  // ======================= SUBMIT =======================

  Future<void> _submit() async {
    if (_selectedDate == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final startDt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final endDt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    setState(() => _isLoading = true);

    try {
      if (widget.isReschedule) {
        // CALL BACKEND
        await _service.rescheduleBooking(
          bookingId: widget.initialBooking!.id,
          newStartTime: startDt,
          newEndTime: endDt,
        );

        // RETURN updated object
        Navigator.pop(
          context,
          widget.initialBooking!.copyWith(
            startTime: startDt,
            endTime: endDt,
            status: BookingStatus.rescheduled,
          ),
        );
      } else {
        // DUMMY COACH ID → diganti nanti dari Coach Detail Page
        const coachId = 1;

        await _service.createBooking(
          coachId: coachId,
          location: _locationController.text,
          startTime: startDt,
        );

        Navigator.pop(
          context,
          Booking(
            id: DateTime.now().millisecondsSinceEpoch,
            coachName: "Coach Name",
            sport: "Football",
            location: _locationController.text,
            startTime: startDt,
            endTime: endDt,
            status: BookingStatus.confirmed,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => _isLoading = false);
  }

  // ======================= UI HELPERS =======================

  Widget _input(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            )),
        const SizedBox(height: 6),
        child,
        const SizedBox(height: 16),
      ],
    );
  }

  InputDecoration _fieldDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30),
      filled: true,
      fillColor: const Color(0xFF1C1C4A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _pickerBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C4A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(text, style: const TextStyle(color: Colors.white70)),
          const Spacer(),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
        ],
      ),
    );
  }

  // ======================= BUILD =======================

  @override
  Widget build(BuildContext context) {
    const indigo = Color(0xFF0F0F38);
    const gold = Color(0xFFD4BC4E);

    final dateText = _selectedDate == null
        ? "Choose date"
        : DateFormat('dd MMM yyyy').format(_selectedDate!);

    final startText =
        _startTime == null ? "Start time" : _startTime!.format(context);

    final endText =
        _endTime == null ? "End time" : _endTime!.format(context);

    return Scaffold(
      backgroundColor: indigo,
      appBar: AppBar(
        backgroundColor: indigo,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.isReschedule ? "Reschedule" : "New Booking",
          style: const TextStyle(color: gold, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _input(
                "Location",
                TextFormField(
                  controller: _locationController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDeco("Enter location"),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Location required" : null,
                ),
              ),
              _input("Date", GestureDetector(onTap: _pickDate, child: _pickerBox(dateText))),
              _input("Start Time", GestureDetector(onTap: _pickStartTime, child: _pickerBox(startText))),
              _input("End Time", GestureDetector(onTap: _pickEndTime, child: _pickerBox(endText))),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(
                        widget.isReschedule ? "Update" : "Confirm",
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
