import 'package:flutter/material.dart';
import 'package:healthcare/screens/user/appointment_review_dialog.dart';
import 'package:healthcare/utils/appointment_user_modal_helpers.dart';
import 'package:healthcare/models/appointment.dart';
import 'package:healthcare/services/appointment_service.dart';
import '/constants/app_colors.dart';
import '/helpers/appointment_status_helper.dart';
import 'package:healthcare/widgets/provider_location_map.dart';
import 'package:healthcare/utils/appointment_helpers.dart';

class AppointmentDetailsModal extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailsModal({Key? key, required this.appointment})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _AppointmentDetailsModal(appointment: appointment);
  }
}

class _AppointmentDetailsModal extends StatelessWidget {
  final Appointment appointment;

  const _AppointmentDetailsModal({required this.appointment});

  void _showReviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ReviewDialog(
        appointmentId: appointment.id,
        providerId: appointment.providerId,
      ),
    );
  }

  Widget _buildDisputeMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.withOpacity(0.1),
            Colors.deepPurple.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.deepPurple.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.deepPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Appointment Under Investigation',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'This appointment is currently being investigated due to a reported issue. Our team will review and get back to you soon.',
            style: TextStyle(
              color: Colors.deepPurple.shade700,
              height: 1.6,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(24),
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Appointment Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(context),
                          splashRadius: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Provider Info
                  _buildProviderInfo(),
                  const SizedBox(height: 20),

                  // Dispute Message
                  if (appointment.status.toLowerCase() == 'disputed')
                    _buildDisputeMessage(),

                  // Appointment Info
                  _buildAppointmentInfo(),
                  const SizedBox(height: 20),

                  // Notes
                  _buildNotes(),
                  const SizedBox(height: 20),

                  // Address
                  _buildAddress(),
                  const SizedBox(height: 20),

                  // Location
                  _buildLocation(),
                  const SizedBox(height: 100), // Space for bottom actions
                ],
              ),
            ),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  ButtonStyle buttonStyle(Color backgroundColor, Color foregroundColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.15),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (isAppointmentCancelable(appointment))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      showCancelConfirmationDialog(context, appointment),
                  icon: const Icon(Icons.cancel_outlined, size: 20),
                  label: const Text('Cancel Appointment',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  style: buttonStyle(Colors.red.withOpacity(0.1), Colors.red),
                ),
              ),
            if (isAppointmentDisputable(appointment))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => showDisputeDialog(context, appointment),
                  icon: const Icon(Icons.warning_amber_rounded, size: 20),
                  label: const Text('Raise Dispute',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  style: buttonStyle(
                      Colors.deepPurple.withOpacity(0.1), Colors.deepPurple),
                ),
              ),
            if (isAppointmentMarkableAsDone(appointment))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => showMarkAsDoneDialog(context, appointment),
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: const Text('Mark Done',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  style:
                      buttonStyle(Colors.green.withOpacity(0.1), Colors.green),
                ),
              ),
            if (appointment.status == 'completed')
              FutureBuilder<bool>(
                future: AppointmentService().hasReview(appointment.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData && !snapshot.data!) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showReviewDialog(context),
                        icon: const Icon(Icons.rate_review_outlined, size: 20),
                        label: const Text('Submit Review',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        style: buttonStyle(AppColors.primary, Colors.white),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => startChat(context, appointment),
                icon: const Icon(Icons.chat_outlined, size: 20),
                label: const Text('Chat',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                style: buttonStyle(AppColors.primary, Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundImage: NetworkImage(appointment.providerImageURL),
              backgroundColor: Colors.grey[100],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.providerName,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appointment.service,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appointment Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.calendar_today_rounded,
            'Date',
            '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.access_time_rounded,
            'Start Time',
            appointment.startTime,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.schedule_rounded,
            'End Time',
            appointment.endTime,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.timer_outlined,
            'Duration',
            '${appointment.duration} minutes',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.payment_rounded,
            'Cost',
            'PKR ${appointment.cost.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          if (appointment.isUserMarkedDone) _buildBadge(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge() {
  return Padding(
    padding: const EdgeInsets.only(top: 0),
    child: Row(
      children: [
        const SizedBox(width: 10), // Align with other rows, or remove if not needed
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.teal.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // This makes the container size adjust to the content
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 14,
                color: Colors.teal,
              ),
              const SizedBox(width: 6),
              Text(
                'Marked Done',
                style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildNotes() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.note_alt_rounded,
                  size: 18,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Notes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withOpacity(0.1),
              ),
            ),
            child: Text(
              appointment.notes,
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.6,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Appointment Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withOpacity(0.1),
              ),
            ),
            child: Text(
              appointment.destinationAddress,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocation() {
    final isConfirmed = appointment.status.toLowerCase() == 'confirmed';
    final isToday = isSameDay(appointment.date, DateTime.now());

    // Parse appointment start and end times
    final startTime = parseTimeString(appointment.startTime);
    final endTime = parseTimeString(appointment.endTime);

    // Get current time
    final now = TimeOfDay.now();

    // Convert times to minutes since midnight for easier comparison
    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    // Check if current time is within the allowed window
    final isWithinTimeWindow =
        currentMinutes >= (startMinutes - 60) && // 1 hour before start
            currentMinutes <= endMinutes; // Until end time

    // Show map only if all conditions are met
    final shouldShowMap = isConfirmed && isToday && isWithinTimeWindow;

    if (!shouldShowMap) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.map_rounded,
                  size: 18,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Provider\'s Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ProviderLocationMap(providerId: appointment.providerId),
          ),
        ],
      ),
    );
  }
}
