import 'dart:async';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../providers/user_provider.dart';
import '../../services/appwrite_auth_service.dart';
import '/constants/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  late String _userId;
  final _appwriteService = AppwriteService();

  @override
  void initState() {
    super.initState();
    _userId = Provider.of<UserProvider>(context, listen: false).userId ?? '';
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (_userId.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      // First clean up old notifications
      await _appwriteService.cleanOldNotifications(_userId);
      
      // Then fetch remaining notifications
      final notifications = await _appwriteService.getNotifications(_userId);
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

  Future<void> _markNotificationAsRead(String notificationId) async {
    try {
      await _appwriteService.markNotificationAsRead(notificationId);
      _loadNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking read: $e')),
        );
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
              const Tab(text: 'Read'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No notifications yet', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadNotifications,
                    child: TabBarView(
                      children: [
                        _NotificationsList(
                          notifications: _notifications.where((n) => !n.isRead).toList(),
                          emptyMessage: 'No unread notifications',
                          markAsRead: _markNotificationAsRead,
                        ),
                        _NotificationsList(
                          notifications: _notifications.where((n) => n.isRead).toList(),
                          emptyMessage: 'No read notifications',
                          markAsRead: _markNotificationAsRead,
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _NotificationsList extends StatelessWidget {
  final List<NotificationModel> notifications;
  final String emptyMessage;
  final Function(String) markAsRead;

  const _NotificationsList({
    required this.notifications,
    required this.emptyMessage,
    required this.markAsRead,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return Center(
        child: Text(emptyMessage, style: const TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) => _NotificationCard(
        notification: notifications[index],
        markAsRead: markAsRead,
      ),
    );
  }
}

class _NotificationCard extends StatefulWidget {
  final NotificationModel notification;
  final Function(String) markAsRead;

  const _NotificationCard({
    required this.notification,
    required this.markAsRead,
  });

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('notification-${widget.notification.id}'), // Fixed: Added unique key
      onVisibilityChanged: (info) {
        if (widget.notification.isRead) return;

        if (info.visibleFraction > 0.5) {
          _timer?.cancel(); // Cancel existing timer if any
          _timer = Timer(const Duration(seconds: 3), () {
            widget.markAsRead(widget.notification.id);
          });
        } else {
          _timer?.cancel();
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          onTap: () => widget.markAsRead(widget.notification.id), // Added: Manual mark as read on tap
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.notification.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(widget.notification.icon, color: widget.notification.color),
          ),
          title: Text(
            widget.notification.title,
            style: TextStyle(
              fontWeight: widget.notification.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(widget.notification.message),
              const SizedBox(height: 4),
              Text(
                _formatTime(widget.notification.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          trailing: widget.notification.isRead
              ? null
              : Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}