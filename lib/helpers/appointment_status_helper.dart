import 'package:flutter/material.dart';
import '/models/appointment_status.dart';

class AppointmentStatusHelper {
  static String getDescription(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.active:
        return 'Your appointment is confirmed and payment has been processed. You\'re all set!';
      case AppointmentStatus.rejected:
        return 'The healthcare provider has declined this appointment request.';
      case AppointmentStatus.pending:
        return 'Your request is awaiting confirmation from the healthcare provider.';
      case AppointmentStatus.confirmed:
        return 'The provider has confirmed. Please complete the payment to secure your appointment.';
      case AppointmentStatus.completed:
        return 'This appointment has been successfully completed.';
      case AppointmentStatus.cancelled:
        return 'This appointment was cancelled.';
    }
  }

  static Color getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.active:
        return Colors.green;
      case AppointmentStatus.rejected:
        return Colors.redAccent;
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.teal;
      case AppointmentStatus.completed:
        return Colors.blue;
      case AppointmentStatus.cancelled:
        return Colors.red;
    }
  }

  static String getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.active:
        return 'Active';
      case AppointmentStatus.rejected:
        return 'Rejected';
      case AppointmentStatus.pending:
        return 'Pending Confirmation';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  static IconData getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.active:
        return Icons.check_circle;
      case AppointmentStatus.rejected:
        return Icons.cancel;
      case AppointmentStatus.pending:
        return Icons.hourglass_empty;
      case AppointmentStatus.confirmed:
        return Icons.thumb_up;
      case AppointmentStatus.completed:
        return Icons.task_alt;
      case AppointmentStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  static AppointmentStatus fromString(String status) {
    try {
      return AppointmentStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == status.toLowerCase(),
        orElse: () => AppointmentStatus.pending,
      );
    } catch (e) {
      debugPrint('Error parsing status: $e');
      return AppointmentStatus.pending;
    }
  }

  static String toShortString(AppointmentStatus status) {
    return status.toString().split('.').last;
  }
}
