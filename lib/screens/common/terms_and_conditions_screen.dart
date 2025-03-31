import 'package:flutter/material.dart';
import '/constants/app_colors.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Introduction',
              'By using our healthcare services application, you agree to these terms and conditions. Please read them carefully.',
            ),
            _buildSection(
              'User Registration',
              '• You must provide accurate and complete information\n'
              '• You are responsible for maintaining your account security\n'
              '• Users must be 18 years or older to create an account\n'
              '• One person may only create one user account',
            ),
            _buildSection(
              'Privacy Policy',
              '• We collect and process personal data as described in our Privacy Policy\n'
              '• Your medical information is protected under applicable healthcare privacy laws\n'
              '• We implement security measures to protect your information',
            ),
            _buildSection(
              'Healthcare Services',
              '• Services are provided by licensed healthcare professionals\n'
              '• Emergency services are not guaranteed\n'
              '• Response times may vary based on provider availability\n'
              '• Medical advice provided through the app is not a substitute for in-person medical care',
            ),
            _buildSection(
              'Appointments and Cancellations',
              '• Users must provide at least 24-hour notice for cancellations\n'
              '• Late cancellations may incur fees\n'
              '• Providers reserve the right to cancel appointments\n'
              '• Payment is required at the time of booking',
            ),
            _buildSection(
              'User Conduct',
              '• Users must not harass healthcare providers\n'
              '• False information is prohibited\n'
              '• Users must not share account credentials\n'
              '• Abuse of the platform will result in account termination',
            ),
            _buildSection(
              'Liability',
              '• We are not liable for medical outcomes\n'
              '• Users assume risks associated with telehealth services\n'
              '• Provider liability is limited to applicable laws\n'
              '• Force majeure conditions apply',
            ),
            _buildSection(
              'Termination',
              'We reserve the right to terminate accounts that violate these terms or for any other reason at our discretion.',
            ),
            _buildSection(
              'Changes to Terms',
              'We may update these terms at any time. Continued use of the app constitutes acceptance of new terms.',
            ),
            const SizedBox(height: 32),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return const Column(
      children: [
        Divider(),
        SizedBox(height: 16),
        Text(
          'Last updated: March 2024',
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'If you have any questions about these terms, please contact us.',
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
