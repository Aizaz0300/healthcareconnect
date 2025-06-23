import 'package:flutter/material.dart';
import 'package:healthcare/models/review.dart';
import 'package:healthcare/services/appwrite_provider_service.dart';
import 'package:provider/provider.dart';
import 'package:healthcare/models/appointment.dart';
import 'package:healthcare/services/appointment_service.dart';
import 'package:healthcare/providers/user_provider.dart';
import '/constants/app_colors.dart';
import '/helpers/appointment_status_helper.dart';
import '/models/appointment_status.dart';
import '/services/chat_service.dart';
import 'chat_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AppointmentService _appointmentService = AppointmentService();
  bool _isLoading = false;
  String? _error;
  List<Appointment> _activeAppointments = [];
  List<Appointment> _historyAppointments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;
    if (userId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final activeAppointments =
          await _appointmentService.getActiveAppointments(userId);
      final historyAppointments =
          await _appointmentService.getHistoryAppointments(userId);

      setState(() {
        _activeAppointments = activeAppointments;
        _historyAppointments = historyAppointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load appointments';
        _isLoading = false;
      });
    }
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Appointment Status Guide',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...AppointmentStatus.values.map((status) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          AppointmentStatusHelper.getStatusIcon(status),
                          color: AppointmentStatusHelper.getStatusColor(status),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppointmentStatusHelper.getStatusText(status),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppointmentStatusHelper.getDescription(status),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfo,
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchAppointments,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchAppointments,
              child: SafeArea(
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverAppBar(
                      expandedHeight: 50,
                      floating: true,
                      pinned: true,
                      backgroundColor: Colors.white,
                      elevation: innerBoxIsScrolled ? 2 : 0,
                      bottom: TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Active'),
                          Tab(text: 'History'),
                        ],
                        labelColor: AppColors.primary,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: AppColors.primary,
                      ),
                    ),
                  ],
                  body: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _AppointmentsList(
                                appointments: _activeAppointments),
                            _AppointmentsList(
                                appointments: _historyAppointments),
                          ],
                        ),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _AppointmentsList extends StatelessWidget {
  final List<Appointment> appointments;

  const _AppointmentsList({required this.appointments});

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No appointments found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your appointments will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return _AppointmentCard(
          appointment: appointments[index],
          onTap: () => _showAppointmentDetails(context, appointments[index]),
        );
      },
    );
  }

  void _showAppointmentDetails(BuildContext context, Appointment appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AppointmentDetailsModal(appointment: appointment),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onTap;

  const _AppointmentCard({
    required this.appointment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Provider Info Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Image.network(
                      appointment.providerImageURL,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey[300],
                          child: const Icon(Icons.person, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.providerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.service,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(appointment.status),
                ],
              ),

              const SizedBox(height: 16),

              // Appointment Info Row
              Wrap(
                spacing: 16,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildInfoItem(Icons.calendar_today,
                      '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}'),
                  _buildInfoItem(Icons.access_time,
                      '${appointment.startTime} (${appointment.duration}min)'),
                  _buildInfoItem(Icons.attach_money, 'PKR ${appointment.cost}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color.fromARGB(255, 27, 8, 201)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    final appointmentStatus = AppointmentStatusHelper.fromString(status);
    final color = AppointmentStatusHelper.getStatusColor(appointmentStatus);
    final text = AppointmentStatusHelper.getStatusText(appointmentStatus);

    return Tooltip(
      message: AppointmentStatusHelper.getDescription(appointmentStatus),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppointmentStatusHelper.getStatusIcon(appointmentStatus),
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentDetailsModal extends StatelessWidget {
  final Appointment appointment;

  const _AppointmentDetailsModal({required this.appointment});

  bool get _canBeCancelled {
    final status = AppointmentStatusHelper.fromString(appointment.status);
    if (status != AppointmentStatus.confirmed &&
        status != AppointmentStatus.pending) {
      return false;
    }
    final now = DateTime.now();
    if (appointment.date.isBefore(now) && !isSameDay(appointment.date, now)) {
      return false;
    }

    // Case 1: If appointment is today and status is confirmed, don't allow cancellation
    if (status == AppointmentStatus.confirmed &&
        isSameDay(appointment.date, DateTime.now())) {
      return false;
    }

    return true;
  }

  bool get _canBeDisputed {
    final status = AppointmentStatusHelper.fromString(appointment.status);
    if (appointment.isUserMarkedDone ||
        status != AppointmentStatus.confirmed ||
        status == AppointmentStatus.disputed) {
      return false;
    }
    final now = DateTime.now();
    // If appointment is in the past and not today
    if (appointment.date.isBefore(now) && !isSameDay(appointment.date, now)) {
      return true;
    }
    // If appointment is today, compare current time with end time
    if (isSameDay(appointment.date, now)) {
      final endTime = parseTimeString(appointment.endTime);
      return _isTimeAfter(TimeOfDay.now(), endTime);
    }

    return false;
  }

  bool get _canBeMarkedDone {
    final status = AppointmentStatusHelper.fromString(appointment.status);
    if (appointment.isUserMarkedDone ||
        status != AppointmentStatus.confirmed ||
        status == AppointmentStatus.disputed) {
      return false;
    }
    final now = DateTime.now();
    // If appointment is in the past and not today
    if (appointment.date.isBefore(now) && !isSameDay(appointment.date, now)) {
      return true;
    }
    // If appointment is today, compare current time with end time
    if (isSameDay(appointment.date, now)) {
      final endTime = parseTimeString(appointment.endTime);
      return _isTimeAfter(TimeOfDay.now(), endTime);
    }
    return false;
  }

  // Helper method to compare TimeOfDay
  bool _isTimeAfter(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour > time2.hour) return true;
    if (time1.hour < time2.hour) return false;
    return time1.minute > time2.minute;
  }

  // Updated time parsing method to handle both 12-hour and 24-hour formats
  TimeOfDay parseTimeString(String timeStr) {
    try {
      final trimmed = timeStr.trim();
      if (trimmed.toUpperCase().contains('AM') ||
          trimmed.toUpperCase().contains('PM')) {
        // Handle 12-hour format
        final parts = trimmed.split(' ');
        final timeParts = parts[0].split(':');
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);

        if (parts[1].toUpperCase() == 'PM' && hour != 12) {
          hour += 12;
        }
        if (parts[1].toUpperCase() == 'AM' && hour == 12) {
          hour = 0;
        }

        return TimeOfDay(hour: hour, minute: minute);
      } else {
        // Handle 24-hour format
        final parts = trimmed.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      debugPrint('Error parsing time: $e');
      return TimeOfDay.now();
    }
  }

  // Helper method to check if two dates are the same day
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _showCancelConfirmation(BuildContext context) {
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

  void _showDisputeDialog(BuildContext context) {
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
            Text('• The provider didn\'t show up',
                style: TextStyle(color: Colors.grey[700])),
            Text(
                '• The service was significantly different from what was promised',
                style: TextStyle(color: Colors.grey[700])),
            Text('• There were serious quality or safety concerns',
                style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 16),
            const Text(
              'Warning: False disputes may result in account restrictions.',
              style: TextStyle(color: Colors.red),
            ),
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
                  Navigator.pop(context,true); // Close modal
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

  void _showMarkAsDoneDialog(BuildContext context) {
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
                  Navigator.pop(context,true);  // Close modal
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

  void _startChat(BuildContext context) async {
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.deepPurple.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.deepPurple,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Appointment Under Investigation',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'This appointment is currently being investigated due to a reported issue. Our team will review and get back to you soon.',
            style: TextStyle(
              color: Colors.deepPurple.shade700,
              height: 1.5,
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Appointment Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildProviderInfo(),
                  const SizedBox(height: 20),
                  if (appointment.status.toLowerCase() == 'disputed')
                    Column(
                      children: [
                        _buildDisputeMessage(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  _buildAppointmentInfo(),
                  const SizedBox(height: 20),
                  _buildNotes(),
                  const SizedBox(height: 20),
                  _buildLocation(),
                  const SizedBox(height: 20),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      minimumSize: const Size(double.infinity, 48),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_canBeCancelled)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showCancelConfirmation(context),
                icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                label: const Text('Cancel Appointment'),
                style: buttonStyle(Colors.red.withOpacity(0.1), Colors.red),
              ),
            ),
          if (_canBeCancelled) const SizedBox(width: 16),
          if (_canBeDisputed)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showDisputeDialog(context),
                icon: const Icon(Icons.warning_amber_rounded,
                    color: Colors.deepPurple),
                label: const Text('Raise Dispute'),
                style: buttonStyle(
                    Colors.deepPurple.withOpacity(0.1), Colors.deepPurple),
              ),
            ),
          if (_canBeDisputed) const SizedBox(width: 16),
          if (_canBeMarkedDone)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showMarkAsDoneDialog(context),
                icon:
                    const Icon(Icons.check_circle_outline, color: Colors.green),
                label: const Text('Mark Done'),
                style: buttonStyle(Colors.green.withOpacity(0.1), Colors.green),
              ),
            ),
          if (_canBeMarkedDone) const SizedBox(width: 16),
          if (appointment.status == 'completed')
            FutureBuilder<bool>(
              future: AppointmentService().hasReview(appointment.id),
              builder: (context, snapshot) {
                if (snapshot.hasData && !snapshot.data!) {
                  return Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showReviewDialog(context),
                      icon: const Icon(Icons.rate_review_outlined),
                      label: const Text('Submit Review'),
                      style: buttonStyle(AppColors.primary, Colors.white),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          if (appointment.status == 'completed') const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _startChat(context),
              icon: const Icon(Icons.chat_outlined),
              label: const Text('Chat'),
              style: buttonStyle(AppColors.primary, Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(appointment.providerImageURL),
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.providerName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appointment.service,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('Date',
                '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}'),
            const SizedBox(height: 6),
            _buildInfoRow('Start Time', '${appointment.startTime}'),
            const SizedBox(height: 6),
            _buildInfoRow('End Time', '${appointment.endTime}'),
            const SizedBox(height: 6),
            _buildInfoRow('Duration', '${appointment.duration} minutes'),
            const SizedBox(height: 6),
            _buildInfoRow('Cost', 'PKR ${appointment.cost.toStringAsFixed(2)}'),
            const SizedBox(height: 6),
            _buildInfoRow(
              'Status',
              AppointmentStatusHelper.getStatusText(
                  AppointmentStatusHelper.fromString(appointment.status)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textLight)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500))
      ],
    );
  }

  Widget _buildNotes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              appointment.notes,
              style: TextStyle(
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appointment.destinationAddress,
                    style: TextStyle(
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewDialog extends StatefulWidget {
  final String appointmentId;
  final String providerId;

  const ReviewDialog({
    Key? key,
    required this.appointmentId,
    required this.providerId,
  }) : super(key: key);

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  double _rating = 5.0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a comment')),
      );
      return;
    }

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final review = Review(
        id: widget.appointmentId,
        userName: '${userProvider.firstName} ${userProvider.lastName}',
        userImage: userProvider.profileImage ?? '',
        rating: _rating,
        comment: _commentController.text.trim(),
        date: DateTime.now(),
      );

      final providerService = AppwriteProviderService();
      await providerService.submitReview(widget.providerId, review);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully')),
        );
      }
      // Mark the appointment as reviewed
      await AppointmentService().markReviewSubmitted(widget.appointmentId);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Rate your experience',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () => setState(() => _rating = index + 1.0),
                );
              }),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Write your review...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('SUBMIT'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
