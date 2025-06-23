import 'package:flutter/material.dart';
import 'package:healthcare/providers/service_provider_provider.dart';
import 'package:healthcare/screens/provider/provider_chat_screen.dart';
import 'package:healthcare/services/chat_service.dart';
import 'package:provider/provider.dart';
import '/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:healthcare/models/appointment.dart';
import 'package:healthcare/services/appointment_service.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  final Appointment appointment;

  const AppointmentDetailsScreen({Key? key, required this.appointment})
      : super(key: key);

  @override
  State<AppointmentDetailsScreen> createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  late GoogleMapController _mapController;
  late LatLng _appointmentLocation;
  late Set<Marker> _markers;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _appointmentLocation = const LatLng(37.7749, -122.4194);
    _markers = {
      Marker(
        markerId: const MarkerId('appointment_location'),
        position: _appointmentLocation,
        infoWindow: InfoWindow(title: widget.appointment.destinationAddress),
      ),
    };

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  bool _canBeMarkedDone() {
    if (widget.appointment.isProviderMarkedDone) return false;
    if (widget.appointment.status != 'confirmed') return false;
    if (widget.appointment.status == 'disputed') return false;
    if (widget.appointment.status == 'cancelled') return false;

    final now = DateTime.now();
    // If appointment is in the past and not today
    if (widget.appointment.date.isBefore(now) &&
        !_isSameDay(widget.appointment.date, now)) {
      return true;
    }

    // If appointment is today, check if current time is after end time
    if (_isSameDay(widget.appointment.date, now)) {
      final endTime = parseTimeString(widget.appointment.endTime);
      return _isTimeAfter(TimeOfDay.now(), endTime);
    }

    return false;
  }

  bool _canBeDisputed() {
    if (widget.appointment.isProviderMarkedDone) return false;
    if (widget.appointment.status != 'confirmed') return false;
    if (widget.appointment.status == 'disputed') return false;
    if (widget.appointment.status == 'cancelled') return false;

    final now = DateTime.now();

    // If appointment is in the past and not today
    if (widget.appointment.date.isBefore(now) &&
        !_isSameDay(widget.appointment.date, now)) {
      return true;
    }

    // If appointment is today, check if current time is after end time
    if (_isSameDay(widget.appointment.date, now)) {
      final endTime = parseTimeString(widget.appointment.endTime);
      return _isTimeAfter(TimeOfDay.now(), endTime);
    }

    return false;
  }

  void _showMarkAsDoneDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Appointment as Done'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please confirm that:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('• You have provided all services as scheduled',
                style: TextStyle(color: Colors.grey[700])),
            Text('• The client has received the service',
                style: TextStyle(color: Colors.grey[700])),
            Text('• Payment has been received',
                style: TextStyle(color: Colors.grey[700])),
            Text('• The appointment was completed successfully',
                style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 16),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.blue),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => _handleMarkAsDone(),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('MARK AS DONE'),
          ),
        ],
      ),
    );
  }

  void _showDisputeDialog() {
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
            Text('• The client wasn\'t on the intended location',
                style: TextStyle(color: Colors.grey[700])),
            Text('• There were payment issues',
                style: TextStyle(color: Colors.grey[700])),
            Text('• There were serious behavioral concerns',
                style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 16),
            const Text(
              'Warning: False disputes may affect your provider status.',
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
            onPressed: () => _handleDispute(),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('RAISE DISPUTE'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMarkAsDone() async {
    try {
      await _appointmentService
          .markAppointmentAsDoneByProvider(widget.appointment.id);
      Navigator.pop(context); // Close dialog
      Navigator.pop(context, true); // Close screen and refresh list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment marked as done')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _handleDispute() async {
    try {
      await _appointmentService.updateAppointmentStatus(
          widget.appointment.id, 'disputed');
      Navigator.pop(context); // Close dialog
      Navigator.pop(context, true); // Close screen and refresh list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dispute has been raised')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  bool _isTimeAfter(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour > time2.hour) return true;
    if (time1.hour < time2.hour) return false;
    return time1.minute > time2.minute;
  }

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

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildDisputeMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Appointment Under Investigation',
                style: TextStyle(
                  color: Colors.red,
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
              color: Colors.red.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('EEEE, MMMM d, yyyy').format(widget.appointment.date);
    final formattedTime =
        '${widget.appointment.startTime} - ${widget.appointment.endTime}';

    final bool isPending = widget.appointment.status.toLowerCase() == 'pending';
    final bool isCompleted =
        widget.appointment.status.toLowerCase() == 'completed';
    final bool isActive = widget.appointment.status.toLowerCase() == 'active';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Appointment Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF6F6F6),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (widget.appointment.status.toLowerCase() == 'disputed')
              _buildDisputeMessage(),
            if (widget.appointment.status.toLowerCase() == 'disputed')
              const SizedBox(height: 12),
            _buildCard(_buildClientInfoSection()),
            const SizedBox(height: 12),
            _buildCard(
                _buildAppointmentDetailsSection(formattedDate, formattedTime)),
            if (isActive) ...[
              const SizedBox(height: 12),
              _buildCard(_buildLocationSection()),
            ],
            const SizedBox(height: 12),
            _buildCard(_buildActionButtonsSection(isPending, isCompleted)),
            if (isPending) ...[
              const SizedBox(height: 12),
              _buildCard(_buildPendingActionButtons()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildClientInfoSection() {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundImage: NetworkImage(widget.appointment.userImageURL),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.appointment.username,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 8),
              _buildStatusBadge(widget.appointment.status),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentDetailsSection(
      String formattedDate, String formattedTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem(Icons.location_on, 'Address',
            widget.appointment.destinationAddress),
        _buildDetailItem(Icons.medical_services_outlined, 'Service',
            widget.appointment.service),
        _buildDetailItem(Icons.calendar_today, 'Date', formattedDate),
        _buildDetailItem(Icons.access_time, 'Time', formattedTime),
        _buildDetailItem(
            Icons.attach_money, 'Fee', 'PKR ${widget.appointment.cost}'),
        if (widget.appointment.notes.isNotEmpty) ...[
          _buildDetailItem(Icons.note, 'Notes', widget.appointment.notes),
        ],
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          clipBehavior: Clip.antiAlias,
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _appointmentLocation,
                    zoom: 15,
                  ),
                  markers: _markers,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  myLocationEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _launchMaps,
          icon: const Icon(Icons.directions),
          label: const Text('Get Directions'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
            minimumSize: const Size(double.infinity, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtonsSection(bool isPending, bool isCompleted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_canBeMarkedDone())
          ElevatedButton.icon(
            onPressed: _showMarkAsDoneDialog,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Mark as Done'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(double.infinity, 45),
            ),
          ),
        if (_canBeMarkedDone()) const SizedBox(height: 12),
        if (_canBeDisputed())
          ElevatedButton.icon(
            onPressed: _showDisputeDialog,
            icon: const Icon(Icons.warning_amber_rounded),
            label: const Text('Raise Dispute'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              minimumSize: const Size(double.infinity, 45),
            ),
          ),
        if (_canBeDisputed()) const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _launchChat(context),
          icon: const Icon(Icons.chat),
          label: const Text('Chat'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            minimumSize: const Size(double.infinity, 45),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _handleDecline,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              minimumSize: const Size(0, 45),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Decline'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _handleAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(0, 45),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Accept'),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'confirmed':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case 'cancelled':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
      case 'completed':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
            color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _handleAccept() async {
    try {
      await _appointmentService.updateAppointmentStatus(
          widget.appointment.id, 'confirmed');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment accepted successfully')),
        );
        Navigator.pop(context, true); // Pass true to indicate refresh needed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error accepting appointment: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleDecline() async {
    try {
      await _appointmentService.updateAppointmentStatus(
          widget.appointment.id, 'rejected');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment declined successfully')),
        );
        Navigator.pop(context, true); // Pass true to indicate refresh needed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error declining appointment: ${e.toString()}')),
        );
      }
    }
  }

  void _launchMaps() async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${_appointmentLocation.latitude},${_appointmentLocation.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _launchChat(BuildContext context) async {
    try {
      final chatService = ChatService();
      final provider = context.read<ServiceProviderProvider>().provider;
      final providerId = provider?.id;

      if (providerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Provider information not available')),
        );
        return;
      }

      final chat = await chatService.getOrCreateChat(
        userId: widget.appointment.userId,
        providerId: providerId,
        providerName: provider?.name ?? 'Unknown Provider',
        userName: widget.appointment.username,
      );

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProviderChatScreen(
              chatId: chat.$id,
              patientId: widget.appointment.userId,
              patientName: widget.appointment.username,
              currentUserId: providerId,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start chat: ${e.toString()}')),
        );
      }
    }
  }
}
