import 'package:flutter/material.dart';
import '/constants/app_colors.dart';
import '/screens/user/home_screen.dart';

class AppointmentConfirmationScreen extends StatelessWidget {
  const AppointmentConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 24),
              const Text(
                'Appointment Confirmed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your appointment has been successfully scheduled',
                style: TextStyle(color: AppColors.textLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildAppointmentDetails(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                ),
                child: const Text('Back to Home'),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Implement calendar integration
                },
                child: const Text('Add to Calendar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.person,
            label: 'Doctor',
            value: 'Dr. John Doe',
          ),
          const Divider(),
          _buildDetailRow(
            icon: Icons.calendar_today,
            label: 'Date',
            value: 'Monday, Dec 20, 2023',
          ),
          const Divider(),
          _buildDetailRow(
            icon: Icons.access_time,
            label: 'Time',
            value: '10:00 AM',
          ),
          const Divider(),
          _buildDetailRow(
            icon: Icons.location_on,
            label: 'Location',
            value: 'City Medical Center',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}