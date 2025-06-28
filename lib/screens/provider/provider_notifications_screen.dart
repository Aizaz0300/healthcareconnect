import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../providers/service_provider_provider.dart';
import '../../services/appwrite_service.dart';
import '/constants/app_colors.dart';

class ProviderNotificationsScreen extends StatefulWidget {
  const ProviderNotificationsScreen({super.key});

  @override
  State<ProviderNotificationsScreen> createState() => _ProviderNotificationsScreenState();
}

class _ProviderNotificationsScreenState extends State<ProviderNotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  late String _providerId;
  final _appwriteService = AppwriteService();

  @override
  void initState() {
    super.initState();
    _providerId = Provider.of<ServiceProviderProvider>(context, listen: false)
            .provider
            ?.id ??
        '';
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (_providerId.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await _appwriteService.cleanOldNotifications(_providerId);
      final notifications = await _appwriteService.getNotifications(_providerId);
      if (mounted) {
        setState(() {
          _notifications = notifications
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notifications: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Unread'),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _notifications.where((n) => !n.isRead).length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Tab(text: 'All'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadNotifications,
                child: TabBarView(
                  children: [
                    _buildNotificationsList(
                        _notifications.where((n) => !n.isRead).toList()),
                    _buildNotificationsList(_notifications),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications) {
    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No notifications', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: notification.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(notification.icon, color: notification.color),
            ),
            title: Text(
              notification.title,
              style: TextStyle(
                fontWeight:
                    notification.isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(notification.message),
                const SizedBox(height: 4),
                Text(
                  _formatTime(notification.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            trailing: notification.isRead
                ? null
                : Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
            onTap: () async {
              if (!notification.isRead) {
                await _appwriteService
                    .markNotificationAsRead(notification.id);
                _loadNotifications();
              }
            },
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();

    // Calculate the difference in components
    var yearsDiff = now.year - time.year;
    var monthsDiff = now.month - time.month;
    var daysDiff = now.day - time.day;
    var hoursDiff = now.hour - time.hour;
    var minutesDiff = now.minute - time.minute;


    // Adjust for negative values in minutes
    if (minutesDiff < 0) {
      minutesDiff += 60;
      hoursDiff -= 1;
    }

    // Adjust for negative values in hours
    if (hoursDiff < 0) {
      hoursDiff += 24;
      daysDiff -= 1;
    }

    // Adjust for negative values in days
    if (daysDiff < 0) {
      final previousMonth = DateTime(now.year, now.month, 0);
      daysDiff += previousMonth.day; // Get the days in the previous month
      monthsDiff -= 1;
    }

    // Adjust for negative values in months
    if (monthsDiff < 0) {
      monthsDiff += 12;
      yearsDiff -= 1;
    }

    // Now format the output based on the difference
    if (yearsDiff > 0) {
      return '$yearsDiff year${yearsDiff > 1 ? 's' : ''} ago';
    }
    if (monthsDiff > 0) {
      return '$monthsDiff month${monthsDiff > 1 ? 's' : ''} ago';
    }
    if (daysDiff > 0) {
      return '$daysDiff day${daysDiff > 1 ? 's' : ''} ago';
    }
    if (hoursDiff > 0) {
      return '$hoursDiff hour${hoursDiff > 1 ? 's' : ''} ago';
    }
    if (minutesDiff > 0) {
      return '$minutesDiff minute${minutesDiff > 1 ? 's' : ''} ago';
    }
    return 'Just now'; // If it's less than a minute, return "Just now"
  }
}
