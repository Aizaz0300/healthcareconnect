import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '/constants/app_colors.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  State<AppointmentBookingScreen> createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  TimeOfDay? _selectedTime;
  int _selectedDuration = 30;
  final _reasonController = TextEditingController();
  final List<TimeOfDay> _availableTimeSlots = [];
  final List<int> _availableDurations = [30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    _generateTimeSlots();
  }

  void _generateTimeSlots() {
    List<TimeOfDay> slots = [];
    int hour = 9;
    int minute = 0;
    while (hour < 17 || (hour == 17 && minute == 0)) {
      slots.add(TimeOfDay(hour: hour, minute: minute));
      minute += 30;
      if (minute >= 60) {
        minute = 0;
        hour += 1;
      }
    }
    setState(() => _availableTimeSlots.addAll(slots));
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute $period';
  }

  TimeOfDay _calculateEndTime(TimeOfDay startTime, int duration) {
    int startMinutes = startTime.hour * 60 + startTime.minute;
    int endMinutes = startMinutes + duration;
    return TimeOfDay(
      hour: endMinutes ~/ 60,
      minute: endMinutes % 60,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCalendar(),
            _buildTimeSelection(),
            _buildDurationSelection(),
            if (_selectedTime != null) _buildBookingDetails(),
            _buildNotes(),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(bottom: 16), // Margin at the bottom of the button
              child: _buildBookButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernCard({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 90)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedTime = null;
                _selectedDuration = 30;
              });
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              weekendTextStyle: const TextStyle(color: Colors.redAccent),
              todayTextStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildTimeSelection() {
    return _modernCard(
      title: 'Select Start Time',
      child: DropdownButtonFormField<TimeOfDay>(
        value: _selectedTime,
        items: _availableTimeSlots
            .map((time) => DropdownMenuItem(
          value: time,
          child: Text(_formatTimeOfDay(time)),
        ))
            .toList(),
        onChanged: (value) => setState(() {
          _selectedTime = value;
          _selectedDuration = 30;
        }),
        decoration: const InputDecoration(
          hintText: 'Choose time',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildDurationSelection() {
    return _modernCard(
      title: 'Session Duration',
      child: Wrap(
        spacing: 3,
        runSpacing: 5,
        children: _availableDurations.map((duration) {
          final isSelected = _selectedDuration == duration;
          return ChoiceChip(
            label: Text('$duration min'),
            selected: isSelected,
            onSelected: _selectedTime != null
                ? (_) => setState(() => _selectedDuration = duration)
                : null,
            backgroundColor: Colors.grey[100],
            selectedColor: AppColors.primary.withOpacity(0.2),
            labelStyle: TextStyle(
              color: isSelected ? AppColors.primary : Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isSelected ? AppColors.primary : Colors.grey.shade300),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBookingDetails() {
    final endTime = _calculateEndTime(_selectedTime!, _selectedDuration);
    final totalCost = _selectedDuration * 1.0;

    return _modernCard(
      title: 'Booking Details',
      child: Column(
        children: [
          _buildDetailRow('Start Time', _formatTimeOfDay(_selectedTime!)),
          _buildDetailRow('End Time', _formatTimeOfDay(endTime)),
          _buildDetailRow('Duration', '$_selectedDuration minutes'),
          _buildDetailRow('Cost', '${totalCost.toStringAsFixed(0)} Rs'),
        ],
      ),
    );
  }


  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(width: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildNotes() {
    return _modernCard(
      title: 'Notes for the Provider',
      child: Stack(
        children: [
          TextField(
            controller: _reasonController,
            decoration: const InputDecoration(
              hintText: 'Describe your condition or needs',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10), // Add padding to leave space for the icon
            ),
            maxLines: 5,
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Icon(Icons.note_alt_outlined),
          ),
        ],
      ),
    );
  }



  Widget _buildBookButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Confirm Booking'),
        onPressed: _validateAndBook,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }


  void _validateAndBook() {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a time')));
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => _BookingSummary(
        date: _selectedDay,
        time: _selectedTime!,
        duration: _selectedDuration,
        notes: _reasonController.text,
        onConfirm: () {
          Navigator.pop(context);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment booked successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }
}

class _BookingSummary extends StatelessWidget {
  final DateTime date;
  final TimeOfDay time;
  final int duration;
  final String notes;
  final VoidCallback onConfirm;

  const _BookingSummary({
    required this.date,
    required this.time,
    required this.duration,
    required this.notes,
    required this.onConfirm,
  });

  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute $period';
  }

  TimeOfDay _calculateEndTime() {
    int startMinutes = time.hour * 60 + time.minute;
    int endMinutes = startMinutes + duration;
    return TimeOfDay(
      hour: endMinutes ~/ 60,
      minute: endMinutes % 60,
    );
  }

  @override
  Widget build(BuildContext context) {
    final endTime = _calculateEndTime();
    final totalCost = duration * 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Booking Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildInfoRow('Date', '${date.day}/${date.month}/${date.year}'),
          _buildInfoRow('Start Time', formatTimeOfDay(time)),
          _buildInfoRow('End Time', formatTimeOfDay(endTime)),
          _buildInfoRow('Duration', '$duration minutes'),
          _buildInfoRow('Cost', '\$${totalCost.toStringAsFixed(2)}'),
          if (notes.isNotEmpty) _buildInfoRow('Notes', notes),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
              const SizedBox(width: 16),
              Expanded(child: ElevatedButton(onPressed: onConfirm, child: const Text('Confirm'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: AppColors.textLight))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }


}