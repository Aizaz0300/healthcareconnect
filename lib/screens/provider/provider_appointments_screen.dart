import 'package:flutter/material.dart';
import '/constants/app_colors.dart';

  class ProviderAppointmentsScreen extends StatelessWidget {
  const ProviderAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Appointments'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AppointmentsList(
              appointments: _generateDummyAppointments(true),
            ),
            _AppointmentsList(
              appointments: _generateDummyAppointments(false),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _generateDummyAppointments(bool isActive) {
    return List.generate(
      5,
          (index) => {
        'patientName': 'Patient ${index + 1}',
        'service': 'Physiotherapy Session',
        'dateTime': DateTime.now().add(
          Duration(days: isActive ? index : -index - 1),
        ),
        'status': isActive ? 'Upcoming' : 'Completed',
      },
    );
  }
}

class _AppointmentsList extends StatelessWidget {
  final List<Map<String, dynamic>> appointments;

  const _AppointmentsList({
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return _AppointmentCard(
          patientName: appointment['patientName'],
          service: appointment['service'],
          dateTime: appointment['dateTime'],
          status: appointment['status'],
          isActive: appointment['status'] == 'Upcoming',
        );
      },
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final String patientName;
  final String service;
  final DateTime dateTime;
  final String status;
  final bool isActive;

  const _AppointmentCard({
    required this.patientName,
    required this.service,
    required this.dateTime,
    required this.status,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        service,
                        style: const TextStyle(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isActive ? Colors.green : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  '${dateTime.day}/${dateTime.month}/${dateTime.year}',
                  style: const TextStyle(
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
            if (isActive) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement chat
                      },
                      icon: const Icon(Icons.chat_outlined),
                      label: const Text('Chat'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement call
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Call'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}