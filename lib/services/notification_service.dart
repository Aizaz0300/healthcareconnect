import 'package:appwrite/appwrite.dart';
import '../models/notification_model.dart';

class NotificationService {
  final Databases databases;
  static const String _database = '67e6393a0009ccfe982e';
  static const String _notificationsCollection = '67e8f5a50008dc31dad3'; 

  NotificationService({required this.databases});

  Future<void> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String message,
  }) async {
    try {
      final notification = NotificationModel(
        id: ID.unique(),
        userId: userId,
        type: type,
        title: title,
        message: message,
        createdAt: DateTime.now(),
      );

      await databases.createDocument(
        databaseId: _database,
        collectionId: _notificationsCollection,
        documentId: notification.id,
        data: notification.toMap(),
      );
    } catch (e) {
      print('Error creating notification: $e');
      rethrow;
    }
  }

  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: _database,
        collectionId: _notificationsCollection,
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('createdAt'),
        ],
      );

      return response.documents.map((doc) {
        return NotificationModel.fromMap(doc.data, doc.$id);
      }).toList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await databases.updateDocument(
        databaseId: _database,
        collectionId: _notificationsCollection,
        documentId: notificationId,
        data: 
        {'isRead': true},
      );
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await databases.deleteDocument(
        databaseId: _database,
        collectionId: _notificationsCollection,
        documentId: notificationId,
      );
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  Future<void> cleanOldNotifications(String userId) async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 15));
      
      final response = await databases.listDocuments(
        databaseId: _database,
        collectionId: _notificationsCollection,
        queries: [
          Query.equal('userId', userId),
          Query.lessThan('createdAt', cutoffDate.toIso8601String()),
        ],
      );

      // Delete old notifications in parallel
      await Future.wait(
        response.documents.map((doc) => databases.deleteDocument(
          databaseId: _database,
          collectionId: _notificationsCollection,
          documentId: doc.$id,
        )),
      );
    } catch (e) {
      print('Error cleaning old notifications: $e');
      rethrow;
    }
  }
}
