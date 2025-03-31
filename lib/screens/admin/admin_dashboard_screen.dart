import 'package:flutter/material.dart';
import '/constants/app_colors.dart';
import '/screens/admin/provider_verification_screen.dart';
import '/screens/admin/complaints_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCards(),
            const SizedBox(height: 24),
            _buildPendingVerifications(context),
            const SizedBox(height: 24),
            _buildRecentComplaints(context),
            const SizedBox(height: 24),
            _buildRevenueChart(),
            const SizedBox(height: 24),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: const [
        _StatisticCard(
          title: 'Total Users',
          value: '1,234',
          icon: Icons.people,
          color: Colors.blue,
        ),
        _StatisticCard(
          title: 'Active Providers',
          value: '89',
          icon: Icons.medical_services,
          color: Colors.green,
        ),
        _StatisticCard(
          title: 'Total Revenue',
          value: '\$12,450',
          icon: Icons.attach_money,
          color: Colors.orange,
        ),
        _StatisticCard(
          title: 'Pending Verifications',
          value: '15',
          icon: Icons.verified_user,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildPendingVerifications(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Pending Verifications',
          onViewAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProviderVerificationScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return _VerificationRequestCard(
              providerName: 'Dr. John Doe',
              specialization: 'Physiotherapist',
              submissionDate: DateTime.now().subtract(Duration(days: index)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentComplaints(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Recent Complaints',
          onViewAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ComplaintsScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return _ComplaintCard(
              userName: 'Jane Smith',
              complaint: 'Issue with appointment scheduling',
              date: DateTime.now().subtract(Duration(hours: index * 5)),
              status: index == 0 ? 'New' : 'In Progress',
            );
          },
        ),
      ],
    );
  }

  Widget _buildRevenueChart() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Text('Chart placeholder'),
                // TODO: Implement actual chart
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return _ActivityItem(
              title: 'New provider registered',
              description: 'Dr. Sarah Johnson submitted verification documents',
              time: DateTime.now().subtract(Duration(hours: index)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          child: const Text('View All'),
        ),
      ],
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatisticCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationRequestCard extends StatelessWidget {
  final String providerName;
  final String specialization;
  final DateTime submissionDate;

  const _VerificationRequestCard({
    required this.providerName,
    required this.specialization,
    required this.submissionDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(providerName),
        subtitle: Text(specialization),
        trailing: Text(
          '${submissionDate.day}/${submissionDate.month}/${submissionDate.year}',
          style: const TextStyle(color: AppColors.textLight),
        ),
        onTap: () {
          // TODO: Navigate to verification details
        },
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final String userName;
  final String complaint;
  final DateTime date;
  final String status;

  const _ComplaintCard({
    required this.userName,
    required this.complaint,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(userName),
        subtitle: Text(complaint),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: status == 'New' ? Colors.red[100] : Colors.orange[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: status == 'New' ? Colors.red : Colors.orange,
              fontSize: 12,
            ),
          ),
        ),
        onTap: () {
          // TODO: Navigate to complaint details
        },
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String description;
  final DateTime time;

  const _ActivityItem({
    required this.title,
    required this.description,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textLight,
                  ),
                ),
                Text(
                  _formatTime(time),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
} 