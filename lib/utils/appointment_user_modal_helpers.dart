import 'package:flutter/material.dart';
import 'package:healthcare/models/appointment.dart';
import 'package:healthcare/models/appointment_status.dart';
import 'package:healthcare/screens/user/chat_screen.dart';
import 'package:healthcare/services/appointment_service.dart';
import 'package:healthcare/helpers/appointment_status_helper.dart';
import 'package:healthcare/utils/appointment_helpers.dart';
import 'package:provider/provider.dart';
import '/services/chat_service.dart';
import 'package:healthcare/providers/user_provider.dart';



bool isAppointmentCancelable(Appointment appointment) {
  final status = AppointmentStatusHelper.fromString(appointment.status);
  if (status != AppointmentStatus.confirmed && status != AppointmentStatus.pending) {
    return false;
  }

  final now = DateTime.now();
  if (appointment.date.isBefore(now) && !isSameDay(appointment.date, now)) {
    return false;
  }

  if (status == AppointmentStatus.confirmed && isSameDay(appointment.date, DateTime.now())) {
    return false;
  }

  return true;
}

/// Helper function to check if the appointment can be disputed.
bool isAppointmentDisputable(Appointment appointment) {
  final status = AppointmentStatusHelper.fromString(appointment.status);
  if (appointment.isUserMarkedDone || status != AppointmentStatus.confirmed || status == AppointmentStatus.disputed) {
    return false;
  }

  final now = DateTime.now();
  if (appointment.date.isBefore(now) && !isSameDay(appointment.date, now)) {
    return true;
  }

  if (isSameDay(appointment.date, now)) {
    final endTime = parseTimeString(appointment.endTime);
    return isTimeAfter(TimeOfDay.now(), endTime);
  }

  return false;
}

/// Helper function to check if the appointment can be marked as done.
bool isAppointmentMarkableAsDone(Appointment appointment) {
  final status = AppointmentStatusHelper.fromString(appointment.status);
  if (appointment.isUserMarkedDone || status != AppointmentStatus.confirmed || status == AppointmentStatus.disputed) {
    return false;
  }

  final now = DateTime.now();
  if (appointment.date.isBefore(now) && !isSameDay(appointment.date, now)) {
    return true;
  }

  if (isSameDay(appointment.date, now)) {
    final endTime = parseTimeString(appointment.endTime);
    return isTimeAfter(TimeOfDay.now(), endTime);
  }

  return false;
}

/// Function to show a cancel appointment confirmation dialog.
void showCancelConfirmationDialog(BuildContext context, Appointment appointment) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cancel Appointment'),
      content: const Text(
        'Are you sure you want to cancel this appointment? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('NO'),
        ),
        TextButton(
          onPressed: () {
            AppointmentService()
                .updateAppointmentStatus(appointment.id, 'cancelled')
                .then((_) {
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close modal
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Appointment cancelled successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }).catchError((e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            });

            Navigator.pop(context); // Close dialog
            Navigator.pop(context); // Close modal
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('YES, CANCEL'),
        ),
      ],
    ),
  );
}

/// Function to show a raise dispute dialog.
void showDisputeDialog(BuildContext context, Appointment appointment) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Raise a Dispute'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Please only raise a dispute if:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('• The provider didn\'t show up', style: TextStyle(color: Colors.grey[700])),
          Text('• The service was significantly different from what was promised', style: TextStyle(color: Colors.grey[700])),
          Text('• There were serious quality or safety concerns', style: TextStyle(color: Colors.grey[700])),
          const SizedBox(height: 16),
          const Text('Warning: False disputes may result in account restrictions.', style: TextStyle(color: Colors.red)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () async {
            try {
              await AppointmentService()
                  .updateAppointmentStatus(appointment.id, 'disputed');
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Close modal
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Appointment marked as disputed'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            }
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('RAISE DISPUTE'),
        ),
      ],
    ),
  );
}

/// Function to show a mark appointment as done dialog.
void showMarkAsDoneDialog(BuildContext context, Appointment appointment) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Mark Appointment as Done'),
      content: const Text(
        'By marking this appointment as done, you confirm that the service was provided as scheduled. This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () async {
            try {
              await AppointmentService()
                  .markAppointmentAsDoneByUser(appointment.id);
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Close modal
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Appointment marked as done'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            }
          },
          style: TextButton.styleFrom(foregroundColor: Colors.green),
          child: const Text('MARK AS DONE'),
        ),
      ],
    ),
  );
}

/// Function to start a chat with the provider.
void startChat(BuildContext context, Appointment appointment) async {
  try {
    final chatService = ChatService();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final username = '${userProvider.firstName} ${userProvider.lastName}';

    if (userProvider.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to chat')),
      );
      return;
    }

    final chat = await chatService.getOrCreateChat(
      userId: userProvider.userId!,
      providerId: appointment.providerId,
      providerName: appointment.providerName,
      userName: username,
    );

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatId: chat.$id,
            providerName: appointment.providerName,
            currentUserId: userProvider.userId!,
            providerId: appointment.providerId,
          ),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start chat: $e')),
      );
    }
  }
}
