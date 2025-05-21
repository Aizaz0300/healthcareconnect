import 'package:flutter/material.dart';
import '/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> appointment;
  
  const AppointmentDetailsScreen({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  State<AppointmentDetailsScreen> createState() => _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  late GoogleMapController _mapController;
  late LatLng _appointmentLocation;
  late Set<Marker> _markers;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // In a real app, you would get actual coordinates from an address
    // For this demo, we'll use fixed coordinates
    _appointmentLocation = const LatLng(37.7749, -122.4194);
    _markers = {
      Marker(
        markerId: const MarkerId('appointment_location'),
        position: _appointmentLocation,
        infoWindow: InfoWindow(title: widget.appointment['location']),
      ),
    };
    
    // Simulate loading map data
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(appointment['dateTime']);
    final formattedTime = DateFormat('h:mm a').format(appointment['dateTime']);
    
    // Determine if this is a pending or confirmed appointment
    final bool isPending = !appointment.containsKey('status');
    final bool isCompleted = appointment.containsKey('status') && appointment['status'] == 'Completed';
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary, 
        title: const Text(
          'Appointment Details',
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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client Information Section
            _buildClientInfoSection(appointment),
            
            // Appointment Details Section
            _buildAppointmentDetailsSection(appointment, formattedDate, formattedTime),
            
            // Location and Map Section
            _buildLocationSection(appointment),
            
            // Action Buttons Section
            _buildActionButtonsSection(appointment, isPending, isCompleted),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfoSection(Map<String, dynamic> appointment) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(appointment['image']),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (appointment.containsKey('status'))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: appointment['status'] == 'Cancelled' 
                              ? Colors.red.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          appointment['status'],
                          style: TextStyle(
                            color: appointment['status'] == 'Cancelled' ? Colors.red : Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          if (appointment.containsKey('rating') && appointment.containsKey('feedback'))
            _buildFeedbackSection(appointment),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection(Map<String, dynamic> appointment) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Client Feedback:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              ...List.generate(
                5,
                (index) => Icon(
                  index < appointment['rating'] ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"${appointment['feedback']}"',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentDetailsSection(Map<String, dynamic> appointment, String formattedDate, String formattedTime) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Appointment Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildDetailRow(Icons.medical_services_outlined, 'Service', appointment['service']),
          const SizedBox(height: 2),
          _buildDetailRow(Icons.calendar_today, 'Date', formattedDate),
          const SizedBox(height: 2),
          _buildDetailRow(Icons.access_time, 'Time', formattedTime),
          const SizedBox(height: 2),
          _buildDetailRow(Icons.attach_money, 'Fee', appointment['fee']),
          const SizedBox(height: 2),
          _buildNotesSection(appointment),
        ],
      ),
    );
  }

  Widget _buildNotesSection(Map<String, dynamic> appointment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.note,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
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
            border: Border.all(color: Colors.grey.shade200),
          ),
          width: double.infinity,
          child: Text(
            appointment['notes'],
            style: TextStyle(
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(Map<String, dynamic> appointment) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildDetailRow(
            Icons.location_on, 
            appointment['location'], 
            '123 Main Street, San Francisco, CA 94105',  // Sample address
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
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
            onPressed: () => _launchMaps(),
            icon: const Icon(Icons.directions),
            label: const Text('Get Directions'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 45),
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsSection(Map<String, dynamic> appointment, bool isPending, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 24),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Client',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launchCall(),
                  icon: const Icon(Icons.call),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(0, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launchChat(),
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    minimumSize: const Size(0, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          if (isPending) 
            _buildPendingActionButtons(),
            
          if (!isPending && !isCompleted)
            _buildUpcomingActionButtons(),
        ],
      ),
    );
  }
  
  Widget _buildPendingActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // Handle decline
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                minimumSize: const Size(0, 45),
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
                // Handle accept
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(0, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Accept'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUpcomingActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // Handle reschedule
              },
              icon: const Icon(Icons.schedule),
              label: const Text('Reschedule'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                minimumSize: const Size(0, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Handle cancel
              },
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(0, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Launch functions for external actions
  void _launchMaps() async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${_appointmentLocation.latitude},${_appointmentLocation.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _launchCall() async {
    const phoneNumber = 'tel:+15551234567'; // Sample phone number
    if (await canLaunch(phoneNumber)) {
      await launch(phoneNumber);
    }
  }

  void _launchChat() {
    // Navigate to chat screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ChatScreen(
    //       clientName: widget.appointment['name'],
    //       clientId: 'client_123', // You would use a real client ID
    //     ),
    //   ),
    // );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chat feature coming soon')),
    );
  }
}