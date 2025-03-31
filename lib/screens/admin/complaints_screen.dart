import 'package:flutter/material.dart';
import '/constants/app_colors.dart';

class ComplaintsScreen extends StatelessWidget {
  const ComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complaints Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'New'),
              Tab(text: 'In Progress'),
              Tab(text: 'Resolved'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ComplaintsList(
              complaints: _getDummyComplaints('New'),
            ),
            _ComplaintsList(
              complaints: _getDummyComplaints('In Progress'),
            ),
            _ComplaintsList(
              complaints: _getDummyComplaints('Resolved'),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getDummyComplaints(String status) {
    return List.generate(
      5,
      (index) => {
        'id': 'COM${1000 + index}',
        'userName': 'User ${index + 1}',
        'userType': index % 2 == 0 ? 'Patient' : 'Service Provider',
        'subject': 'Issue with ${index % 2 == 0 ? 'Service' : 'Payment'}',
        'description': 'Detailed description of the complaint...',
        'date': DateTime.now().subtract(Duration(days: index)),
        'status': status,
        'priority': index % 3 == 0 ? 'High' : (index % 3 == 1 ? 'Medium' : 'Low'),
      },
    );
  }
}

class _ComplaintsList extends StatelessWidget {
  final List<Map<String, dynamic>> complaints;

  const _ComplaintsList({required this.complaints});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: complaints.length,
      itemBuilder: (context, index) {
        final complaint = complaints[index];
        return _ComplaintCard(
          complaint: complaint,
          onTap: () => _showComplaintDetails(context, complaint),
        );
      },
    );
  }

  void _showComplaintDetails(BuildContext context, Map<String, dynamic> complaint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ComplaintDetailsSheet(complaint: complaint),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final Map<String, dynamic> complaint;
  final VoidCallback onTap;

  const _ComplaintCard({
    required this.complaint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _PriorityBadge(priority: complaint['priority']),
                  const SizedBox(width: 8),
                  Text(
                    '#${complaint['id']}',
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  _StatusBadge(status: complaint['status']),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                complaint['subject'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    complaint['userType'] == 'Patient' 
                        ? Icons.person 
                        : Icons.medical_services,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${complaint['userName']} (${complaint['userType']})',
                    style: const TextStyle(
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(complaint['date']),
                    style: const TextStyle(
                      color: AppColors.textLight,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ComplaintDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> complaint;

  const _ComplaintDetailsSheet({required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Complaint #${complaint['id']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _StatusBadge(status: complaint['status']),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailSection('Subject', complaint['subject']),
          _buildDetailSection('Description', complaint['description']),
          _buildDetailSection('Submitted By', 
            '${complaint['userName']} (${complaint['userType']})'
          ),
          _buildDetailSection('Date', _formatDate(complaint['date'])),
          _buildDetailSection('Priority', complaint['priority']),
          const SizedBox(height: 20),
          if (complaint['status'] != 'Resolved') ...[
            const Text(
              'Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showAssignDialog(context),
                    child: const Text('Assign'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showUpdateStatusDialog(context),
                    child: const Text('Update Status'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAssignDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Complaint'),
        content: DropdownButtonFormField<String>(
          items: ['Admin 1', 'Admin 2', 'Admin 3']
              .map((name) => DropdownMenuItem(
                    value: name,
                    child: Text(name),
                  ))
              .toList(),
          onChanged: (value) {},
          decoration: const InputDecoration(
            labelText: 'Select Admin',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement assignment logic
              Navigator.pop(context);
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              items: ['In Progress', 'Resolved']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) {},
              decoration: const InputDecoration(
                labelText: 'Status',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Resolution Notes',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement status update logic
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high':
        color = Colors.red;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      default:
        color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'new':
        color = Colors.blue;
        break;
      case 'in progress':
        color = Colors.orange;
        break;
      case 'resolved':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }
} 