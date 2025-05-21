import 'package:flutter/material.dart';
import 'package:healthcare/screens/provider/appointment_details_screen.dart';  // Fixed import path
import '/constants/app_colors.dart';
import 'package:intl/intl.dart';

class AppointmentRequestsScreen extends StatefulWidget {
  const AppointmentRequestsScreen({super.key});

  @override
  State<AppointmentRequestsScreen> createState() => _AppointmentRequestsScreenState();
}

class _AppointmentRequestsScreenState extends State<AppointmentRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Appointment Requests',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'New'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingRequests(),
          _buildUpcomingAppointments(),
          _buildPastAppointments(),
        ],
      ),
    );
  }

  Widget _buildPendingRequests() {
    final List<Map<String, dynamic>> requests = [
      {
        'name': 'Emma Wilson',
        'image': 'https://randomuser.me/api/portraits/women/32.jpg',
        'service': 'Physiotherapy Session',
        'dateTime': DateTime.now().add(Duration(days: 2, hours: 10)),
        'location': 'Home Visit',
        'notes': 'Experiencing back pain from recent injury',
        'fee': '\$85',
      },
      {
        'name': 'Michael Brown',
        'image': 'https://randomuser.me/api/portraits/men/45.jpg',
        'service': 'Post-surgery Recovery',
        'dateTime': DateTime.now().add(Duration(days: 3, hours: 14)),
        'location': 'Clinic',
        'notes': 'Need follow-up after knee surgery',
        'fee': '\$95',
      },
      {
        'name': 'Sophia Garcia',
        'image': 'https://randomuser.me/api/portraits/women/68.jpg',
        'service': 'Sports Injury Treatment',
        'dateTime': DateTime.now().add(Duration(days: 4, hours: 16)),
        'location': 'Clinic',
        'notes': 'Recurring shoulder pain during tennis',
        'fee': '\$85',
      },
      {
        'name': 'James Wilson',
        'image': 'https://randomuser.me/api/portraits/men/22.jpg',
        'service': 'Mobility Assessment',
        'dateTime': DateTime.now().add(Duration(days: 5, hours: 11)),
        'location': 'Home Visit',
        'notes': 'Need assessment for elderly parent',
        'fee': '\$110',
      },
    ];

    return _buildRequestsList(requests, true);
  }

  Widget _buildUpcomingAppointments() {
    final List<Map<String, dynamic>> appointments = [
      {
        'name': 'John Smith',
        'image': 'https://randomuser.me/api/portraits/men/32.jpg',
        'service': 'Weekly Rehabilitation',
        'dateTime': DateTime.now().add(Duration(days: 1, hours: 9)),
        'location': 'Clinic',
        'notes': 'Third session of weekly therapy',
        'fee': '\$85',
        'status': 'Confirmed',
      },
      {
        'name': 'Lisa Johnson',
        'image': 'https://randomuser.me/api/portraits/women/45.jpg',
        'service': 'Post-operative Care',
        'dateTime': DateTime.now().add(Duration(days: 1, hours: 14)),
        'location': 'Home Visit',
        'notes': 'Needs assistance with exercises',
        'fee': '\$100',
        'status': 'Confirmed',
      },
      {
        'name': 'Robert Taylor',
        'image': 'https://randomuser.me/api/portraits/men/62.jpg',
        'service': 'Chronic Pain Management',
        'dateTime': DateTime.now().add(Duration(days: 2, hours: 11)),
        'location': 'Clinic',
        'notes': 'Follow-up for back pain treatment',
        'fee': '\$85',
        'status': 'Confirmed',
      },
    ];

    return _buildRequestsList(appointments, false);
  }

  Widget _buildPastAppointments() {
    final List<Map<String, dynamic>> pastAppointments = [
      {
        'name': 'Emma Davis',
        'image': 'https://randomuser.me/api/portraits/women/22.jpg',
        'service': 'Physiotherapy Session',
        'dateTime': DateTime.now().subtract(Duration(days: 2, hours: 14)),
        'location': 'Clinic',
        'notes': 'Completed assessment',
        'fee': '\$85',
        'status': 'Completed',
        'rating': 5,
        'feedback': 'Very helpful session, feeling much better already!',
      },
      {
        'name': 'David Wilson',
        'image': 'https://randomuser.me/api/portraits/men/52.jpg',
        'service': 'Mobility Assessment',
        'dateTime': DateTime.now().subtract(Duration(days: 4, hours: 10)),
        'location': 'Home Visit',
        'notes': 'Provided home exercise plan',
        'fee': '\$110',
        'status': 'Completed',
        'rating': 4,
        'feedback': 'Good advice on home adaptations needed.',
      },
      {
        'name': 'Sarah Thompson',
        'image': 'https://randomuser.me/api/portraits/women/63.jpg',
        'service': 'Sports Recovery',
        'dateTime': DateTime.now().subtract(Duration(days: 6, hours: 15)),
        'location': 'Clinic',
        'notes': 'Runner with ankle issues',
        'fee': '\$85',
        'status': 'Cancelled',
        'cancelReason': 'Client had emergency',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pastAppointments.length,
      itemBuilder: (context, index) {
        final appointment = pastAppointments[index];
        return _buildPastAppointmentCard(appointment);
      },
    );
  }

  Widget _buildRequestsList(List<Map<String, dynamic>> requests, bool isPending) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildRequestCard(request, isPending);
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request, bool isPending) {
    final formattedDate = DateFormat('E, MMM d').format(request['dateTime']);
    final formattedTime = DateFormat('h:mm a').format(request['dateTime']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(request['image']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request['service'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      request['status'],
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildRequestDetail(
                          Icons.calendar_today,
                          'Date',
                          formattedDate,
                        ),
                      ),
                      Expanded(
                        child: _buildRequestDetail(
                          Icons.access_time,
                          'Time',
                          formattedTime,
                        ),
                      ),
                      Expanded(
                        child: _buildRequestDetail(
                          Icons.attach_money,
                          'Fee',
                          request['fee'],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildRequestDetail(
                          Icons.location_on,
                          'Location',
                          request['location'],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _buildRequestDetail(
                          Icons.note,
                          'Notes',
                          request['notes'],
                          alignLeft: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (isPending)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Handle decline
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // // Handle accept
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppointmentDetailsScreen(
                              appointment: request,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to appointment details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentDetailsScreen(
                        appointment: request,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility),
                label: const Text('View Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastAppointmentCard(Map<String, dynamic> appointment) {
    final formattedDate = DateFormat('E, MMM d').format(appointment['dateTime']);
    final formattedTime = DateFormat('h:mm a').format(appointment['dateTime']);
    final bool isCancelled = appointment['status'] == 'Cancelled';
    final bool isCompleted = appointment['status'] == 'Completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(appointment['image']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment['service'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCancelled
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment['status'],
                    style: TextStyle(
                      color: isCancelled ? Colors.red : Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildPastAppointmentDetail(Icons.calendar_today, formattedDate),
                const SizedBox(width: 16),
                _buildPastAppointmentDetail(Icons.access_time, formattedTime),
                const SizedBox(width: 16),
                _buildPastAppointmentDetail(Icons.location_on, appointment['location']),
              ],
            ),
            const SizedBox(height: 12),
            if (isCancelled)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.red.shade400,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cancelled: ${appointment['cancelReason']}',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            if (isCompleted && appointment.containsKey('feedback'))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Client Feedback:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...List.generate(
                        5,
                            (index) => Icon(
                          index < appointment['rating'] ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '"${appointment['feedback']}"',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                // // Navigate to appointment details
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => AppointmentDetailsScreen(
                //       appointment: appointment,
                //     ),
                //   ),
                // );
              },
              icon: const Icon(Icons.visibility),
              label: const Text('View Details'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestDetail(IconData icon, String label, String value, {bool alignLeft = false}) {
    return Column(
      crossAxisAlignment: alignLeft ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: alignLeft ? 2 : 1,
          textAlign: alignLeft ? TextAlign.left : TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPastAppointmentDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.primary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}