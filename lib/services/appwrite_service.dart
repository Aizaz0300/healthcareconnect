import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:healthcare/models/notification_model.dart';
import 'package:healthcare/models/service_provider.dart';
import '../constants/api_constants.dart';
import '../models/user_model.dart';
import '../utils/auth_exceptions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/notification_service.dart';

class AppwriteService {
  Client client = Client();
  late Account account;
  late Databases databases;
  late Storage storage;
  late NotificationService _notificationService;

  static const String _usersCollection = '67e63ee90033460e4b77';
  static const String _database = '67e6393a0009ccfe982e';
  static const String _generalStorageBucket = '67e7e8cd002cb16f483a';
  static const String _documentBucketId = '67e8a81c001a021be2be';
  static const String _providerCollection = '67ef8112001cf8d36011';

  AppwriteService() {
    _init();
  }

  void _init() {
    client
        .setEndpoint(ApiConstants.endPoint)
        .setProject(ApiConstants.projectId)
        .setSelfSigned(status: true); // For development only

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
    _notificationService = NotificationService(databases: databases);
  }

  Future<void> createAccount({
    required UserModel user,
    required String password,
  }) async {
    try {
      // Create Appwrite account
      final response = await account.create(
        userId: ID.unique(),
        email: user.email,
        password: password,
        name: '${user.firstName} ${user.lastName}',
      );

      // Store additional user data in database
      await databases.createDocument(
          databaseId: _database,
          collectionId: _usersCollection,
          documentId: response.$id,
          data: user.toMap());

      print("Account created successfully");
    } catch (e) {
      print("Error creating account: $e");
      throw AuthException(AuthException.handleError(e), 'signup_error');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final session = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      print("Login successful");
      // Get user data
      final userData = await databases.getDocument(
        databaseId: _database,
        collectionId: _usersCollection,
        documentId: session.userId,
      );

      print(userData);
      // Store user data in provider
      Provider.of<UserProvider>(context, listen: false)
          .setUserData(userData.data);

      return userData.data;
    } catch (e) {
      throw AuthException(AuthException.handleError(e), 'login_error');
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final currentUser = await account.get();
      final userData = await databases.getDocument(
        databaseId: _database,
        collectionId: _usersCollection,
        documentId: currentUser.$id,
      );
      print(userData.data);
      return userData.data;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      await account.get();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await account.deleteSession(sessionId: 'current');
      Provider.of<UserProvider>(context, listen: false).clearUserData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logged out successfully')),
        );
      }
    } catch (e) {
      throw AuthException(
          'Failed to logout. Please try again.', 'logout_error');
    }
  }

  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data, BuildContext context) async {
    try {
      // Update document
      await databases.updateDocument(
        databaseId: _database,
        collectionId: _usersCollection,
        documentId: userId,
        data: data,
      );

      // Get fresh user data
      final userData = await databases.getDocument(
        databaseId: _database,
        collectionId: _usersCollection,
        documentId: userId,
      );

      // Update UserProvider with fresh data
      if (context.mounted) {
        Provider.of<UserProvider>(context, listen: false)
            .setUserData(userData.data);
      }

      // Print for debugging
      print('Profile updated, new data: ${userData.data}');

      // Create notification
      await _notificationService.createNotification(
        userId: userId,
        type: NotificationType.profile,
        title: 'Profile Updated',
        message: 'Your profile information has been updated successfully',
      );
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<String> uploadProfileImage(
      String userId, String filePath, BuildContext context) async {
    try {
      // Upload file
      final file = await storage.createFile(
        bucketId: _generalStorageBucket,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: filePath),
      );

      // Construct image URL
      final imageUrl =
          '${ApiConstants.endPoint}/storage/buckets/$_generalStorageBucket/files/${file.$id}/view?project=${ApiConstants.projectId}';

      // Update user document with new image URL
      await databases.updateDocument(
        databaseId: _database,
        collectionId: _usersCollection,
        documentId: userId,
        data: {'profileImage': imageUrl},
      );

      // Get fresh user data
      if (context.mounted) {
        final userData = await databases.getDocument(
          databaseId: _database,
          collectionId: _usersCollection,
          documentId: userId,
        );

        // Update UserProvider with fresh data
        Provider.of<UserProvider>(context, listen: false)
            .setUserData(userData.data);

        print('Profile image updated, new data: ${userData.data}');
      }

      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String> uploadFile(String userId, String category, String path) async {
    try {
      String fileName =
          '${userId}/${category}/${DateTime.now().millisecondsSinceEpoch}_${path.split('/').last}';
      InputFile inputFile = InputFile.fromPath(path: path, filename: fileName);

      final result = await storage.createFile(
        bucketId: _documentBucketId,
        fileId: ID.unique(),
        file: inputFile,
        permissions: [
          Permission.read(Role.user(userId)),
          Permission.write(Role.user(userId)),
          Permission.delete(Role.user(userId)),
        ],
      );

      await _notificationService.createNotification(
        userId: userId,
        type: NotificationType.document,
        title: 'Document Uploaded',
        message: 'Successfully uploaded document to $category',
      );

      return storage
          .getFileView(
            bucketId: _documentBucketId,
            fileId: result.$id,
          )
          .toString();
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<FileList> getFilesByCategory(String userId, String category) async {
    try {
      final result = await storage.listFiles(
        bucketId: _documentBucketId,
        queries: [
          Query.contains('name', '$userId/$category/'),
        ],
      );
      return result;
    } catch (e) {
      throw Exception('Failed to fetch files: $e');
    }
  }

  Future<FileList> getFilesByUser(String userId) async {
    try {
      final result = await storage.listFiles(
        bucketId: _documentBucketId,
        queries: [
          Query.contains('name', '$userId/'),
        ],
      );
      return result;
    } catch (e) {
      throw Exception('Failed to fetch files: $e');
    }
  }

  Future<int> getFileCount(String userId, String category) async {
    try {
      final result = await storage.listFiles(
        bucketId: _documentBucketId,
        queries: [
          Query.contains('name', '$userId/$category/'),
        ],
      );
      return result.total;
    } catch (e) {
      print('Error fetching file count: $e');
      return 0;
    }
  }

  Future<void> deleteFile(String fileId) async {
    try {
      await storage.deleteFile(
        bucketId: _documentBucketId,
        fileId: fileId,
      );
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  Future<List<NotificationModel>> getNotifications(String userId) async {
    return _notificationService.getNotifications(userId);
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    return _notificationService.markAsRead(notificationId);
  }

  Future<void> deleteNotification(String notificationId) async {
    return _notificationService.deleteNotification(notificationId);
  }

  Future<void> cleanOldNotifications(String userId) async {
    return _notificationService.cleanOldNotifications(userId);
  }

  Future<List<ServiceProvider>> getServiceProviders(String category) async {
    try {
      final response = await databases.listDocuments(
        databaseId: _database,
        collectionId: _providerCollection,
        queries: [
          Query.equal('services', [category]), // Assuming services is an array
          Query.equal('status', 'approved'), // Only approved providers
        ],
      );

      return response.documents.map((doc) {
        return ServiceProvider.fromJson(doc.data);
      }).toList();
    } catch (e) {
      print('Error fetching service providers: $e');
      throw Exception('Failed to load service providers');
    }
  }
}
