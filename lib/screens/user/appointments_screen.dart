import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '/constants/app_colors.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
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
          body: TabBarView(
            controller: _tabController,
            children: [
              _AppointmentsList(appointments: _getActiveAppointments()),
              _AppointmentsList(appointments: _getHistoryAppointments()),
            ],
          ),
        ),
      ),
    );
  }

  List<AppointmentData> _getActiveAppointments() {
    return [
      AppointmentData(
        id: '1',
        providerName: 'Dr. John Smith',
        providerImage: 'https://example.com/doctor1.jpg',
        serviceName: 'Physiotherapy Session',
        date: DateTime.now().add(const Duration(days: 2)),
        time: const TimeOfDay(hour: 10, minute: 30),
        duration: 60,
        cost: 120.0,
        status: AppointmentStatus.confirmed,
        notes: 'Regular session for back pain treatment',
        location: const LatLng(40.7128, -74.0060),
        address: '123 Healthcare St, New York, NY',
      ),
      AppointmentData(
        id: '3',
        providerName: 'Dr. Emily Carter',
        providerImage: 'https://example.com/doctor3.jpg',
        serviceName: 'Dental Cleaning',
        date: DateTime.now().add(const Duration(days: 4)),
        time: const TimeOfDay(hour: 9, minute: 0),
        duration: 45,
        cost: 100.0,
        status: AppointmentStatus.pending,
        notes: 'Routine dental hygiene appointment',
        location: const LatLng(34.0522, -118.2437),
        address: '789 Smile St, Los Angeles, CA',
      ),
      AppointmentData(
        id: '4',
        providerName: 'Dr. Michael Lee',
        providerImage: 'https://example.com/doctor4.jpg',
        serviceName: 'Chiropractic Adjustment',
        date: DateTime.now().add(const Duration(days: 1)),
        time: const TimeOfDay(hour: 11, minute: 15),
        duration: 30,
        cost: 75.0,
        status: AppointmentStatus.confirmed,
        notes: 'Neck and shoulder adjustment session',
        location: const LatLng(37.7749, -122.4194),
        address: '321 Wellness Blvd, San Francisco, CA',
      ),
    ];
  }

  List<AppointmentData> _getHistoryAppointments() {
    return [
      AppointmentData(
        id: '2',
        providerName: 'Dr. Sarah Wilson',
        providerImage: 'https://example.com/doctor2.jpg',
        serviceName: 'Medical Consultation',
        date: DateTime.now().subtract(const Duration(days: 5)),
        time: const TimeOfDay(hour: 14, minute: 0),
        duration: 30,
        cost: 80.0,
        status: AppointmentStatus.completed,
        notes: 'Follow-up consultation for medication review',
        location: const LatLng(40.7128, -74.0060),
        address: '456 Medical Ave, New York, NY',
      ),
      AppointmentData(
        id: '5',
        providerName: 'Dr. Karen Patel',
        providerImage: 'https://example.com/doctor5.jpg',
        serviceName: 'Eye Examination',
        date: DateTime.now().subtract(const Duration(days: 12)),
        time: const TimeOfDay(hour: 16, minute: 45),
        duration: 40,
        cost: 90.0,
        status: AppointmentStatus.completed,
        notes: 'Routine eye checkup with vision test',
        location: const LatLng(41.8781, -87.6298),
        address: '654 Vision Ln, Chicago, IL',
      ),
      AppointmentData(
        id: '6',
        providerName: 'Dr. Robert Green',
        providerImage: 'https://example.com/doctor6.jpg',
        serviceName: 'Cardiology Consultation',
        date: DateTime.now().subtract(const Duration(days: 20)),
        time: const TimeOfDay(hour: 13, minute: 15),
        duration: 60,
        cost: 150.0,
        status: AppointmentStatus.cancelled,
        notes: 'Patient canceled due to illness',
        location: const LatLng(29.7604, -95.3698),
        address: '987 Heartbeat Rd, Houston, TX',
      ),
    ];
  }

}

class _AppointmentsList extends StatelessWidget {
  final List<AppointmentData> appointments;

  const _AppointmentsList({required this.appointments});

  @override
  Widget build(BuildContext context) {
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

  void _showAppointmentDetails(BuildContext context, AppointmentData appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AppointmentDetailsModal(appointment: appointment),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentData appointment;
  final VoidCallback onTap;

  const _AppointmentCard({
    required this.appointment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Image.network(
                      appointment.providerImage,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 48,
                          height: 48,
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
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.serviceName,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(appointment.status),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoItem(
                    Icons.calendar_today,
                    '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}',
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    Icons.access_time,
                    '${appointment.time.format(context)} (${appointment.duration}min)',
                  ),
                  const Spacer(),
                  Text(
                    '\$${appointment.cost.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
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
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(AppointmentStatus status) {
    Color color;
    String text;

    switch (status) {
      case AppointmentStatus.confirmed:
        color = Colors.green;
        text = 'Confirmed';
        break;
      case AppointmentStatus.completed:
        color = Colors.blue;
        text = 'Completed';
        break;
      case AppointmentStatus.cancelled:
        color = Colors.red;
        text = 'Cancelled';
        break;
      case AppointmentStatus.pending:
        color =Colors.orange;
        text = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _AppointmentDetailsModal extends StatelessWidget {
  final AppointmentData appointment;

  const _AppointmentDetailsModal({required this.appointment});

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
            _buildAppointmentInfo(),
            const SizedBox(height: 20),
            _buildNotes(),
            const SizedBox(height: 20),
            _buildLocation(),
            const SizedBox(height: 20),
            _buildMap(),
          ],
        ),
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
              backgroundImage: NetworkImage(appointment.providerImage),
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
                    appointment.serviceName,
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
            _buildInfoRow('Date', '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}'),
            const SizedBox(height: 6),
            _buildInfoRow('Time', '${appointment.time}'),
            const SizedBox(height: 6),
            _buildInfoRow('Duration', '${appointment.duration} minutes'),
            const SizedBox(height: 6),
            _buildInfoRow('Cost', '\$${appointment.cost.toStringAsFixed(2)}'),
            const SizedBox(height: 6),
            _buildInfoRow('Status', appointment.status.toString().split('.').last),
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
                    appointment.address,
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

  Widget _buildMap() {
    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: appointment.location,
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('provider'),
              position: appointment.location,
              infoWindow: InfoWindow(title: appointment.providerName),
            ),
          },
        ),
      ),
    );
  }
}

enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

class AppointmentData {
  final String id;
  final String providerName;
  final String providerImage;
  final String serviceName;
  final DateTime date;
  final TimeOfDay time;
  final int duration;
  final double cost;
  final AppointmentStatus status;
  final String notes;
  final LatLng location;
  final String address;
  BuildContext? context;

  AppointmentData({
    required this.id,
    required this.providerName,
    required this.providerImage,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.duration,
    required this.cost,
    required this.status,
    required this.notes,
    required this.location,
    required this.address,
    this.context,
  });
}