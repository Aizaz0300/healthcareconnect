import 'package:flutter/material.dart';
import '/models/appointment_status.dart';

class AppointmentStatusHelper {
  static String getDescription(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.rejected:
        return 'The healthcare provider has declined this appointment request.';
      case AppointmentStatus.pending:
        return 'Your request is awaiting confirmation from the healthcare provider.';
      case AppointmentStatus.confirmed:
        return 'Your appointment has been confirmed by the healthcare provider.';
      case AppointmentStatus.completed:
        return 'This appointment has been successfully completed.';
      case AppointmentStatus.cancelled:
        return 'This appointment was cancelled.';
      case AppointmentStatus.disputed:
        return 'This appointment is under review due to a reported issue.';
      case AppointmentStatus.resolved:
        return 'The reported issue has been reviewed and resolved.';
    }
  }

  static Color getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.rejected:
        return Colors.redAccent;
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.completed:
        return Colors.blue;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.disputed:
        return Colors.deepPurple;
      case AppointmentStatus.resolved:
        return Colors.teal;
    }
  }

  static String getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.rejected:
        return 'Rejected';
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.disputed:
        return 'Disputed';
      case AppointmentStatus.resolved:
        return 'Resolved';
    }
  }

  static IconData getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.rejected:
        return Icons.cancel;
      case AppointmentStatus.pending:
        return Icons.hourglass_empty;
      case AppointmentStatus.confirmed:
        return Icons.check_circle;
      case AppointmentStatus.completed:
        return Icons.task_alt;
      case AppointmentStatus.cancelled:
        return Icons.cancel_outlined;
      case AppointmentStatus.disputed:
        return Icons.gavel;
      case AppointmentStatus.resolved:
        return Icons.verified;
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
