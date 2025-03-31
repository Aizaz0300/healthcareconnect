import 'package:flutter/material.dart';
import '/constants/app_colors.dart';

class ProviderVerificationScreen extends StatelessWidget {
  const ProviderVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Verifications'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return _VerificationCard(
            providerName: 'Dr. John Doe',
            specialization: 'Physiotherapist',
            submissionDate: DateTime.now().subtract(Duration(days: index)),
            onViewDetails: () {
              _showVerificationDetails(context);
            },
          );
        },
      ),
    );
  }

  void _showVerificationDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _VerificationDetailsSheet(),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  final String providerName;
  final String specialization;
  final DateTime submissionDate;
  final VoidCallback onViewDetails;

  const _VerificationCard({
    required this.providerName,
    required this.specialization,
    required this.submissionDate,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        providerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        specialization,
                        style: const TextStyle(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
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
                const SizedBox(width: 8),
                Text(
                  'Submitted on ${submissionDate.day}/${submissionDate.month}/${submissionDate.year}',
                  style: const TextStyle(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onViewDetails,
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement verification
                    },
                    child: const Text('Verify'),
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

class _VerificationDetailsSheet extends StatelessWidget {
  const _VerificationDetailsSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verification Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailItem('Full Name', 'Dr. John Doe'),
          _buildDetailItem('Specialization', 'Physiotherapist'),
          _buildDetailItem('Experience', '8 years'),
          _buildDetailItem('License Number', 'PHY123456'),
          const SizedBox(height: 20),
          const Text(
            'Documents',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildDocumentItem('Medical License', 'license.pdf'),
          _buildDocumentItem('Certification', 'certification.pdf'),
          _buildDocumentItem('ID Proof', 'id_proof.pdf'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement verification
                    Navigator.pop(context);
                  },
                  child: const Text('Verify'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String name, String fileName) {
    return ListTile(
      leading: const Icon(Icons.file_present),
      title: Text(name),
      subtitle: Text(fileName),
      trailing: IconButton(
        icon: const Icon(Icons.download),
        onPressed: () {
          // TODO: Implement document download
        },
      ),
    );
  }
} 