import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:healthcare/models/review.dart';
import '../models/service_provider.dart';
import '../constants/api_constants.dart';
import '../utils/auth_exceptions.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

class AppwriteProviderService {
  Client client = Client();
  late Account account;
  late Databases databases;
  late Storage storage;
  late NotificationService _notificationService;

  // Collection and bucket IDs
  static const String _providerCollection = '67ef8112001cf8d36011';
  static const String _database = '67e6393a0009ccfe982e';
  static const String _generalStorageBucket = '67e7e8cd002cb16f483a';

  AppwriteProviderService() {
    _init();
  }

  void _init() {
    client
        .setEndpoint(ApiConstants.endPoint)
        .setProject(ApiConstants.projectId)
        .setSelfSigned(status: true);

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
    _notificationService = NotificationService(databases: databases);
  }

  // Account Creation and Management
  Future<void> createProvider({
    required ServiceProvider provider,
    required String password,
  }) async {
    try {
      // Create Appwrite account
      final response = await account.create(
        userId: ID.unique(),
        email: provider.email,
        password: password,
        name: provider.name,
      );

      final dataToSend = {
        ...provider.toJson(),
        'availability': jsonEncode(provider.availability.toJson()),
        'licenseInfo': jsonEncode(provider.licenseInfo.toJson()),
        'socialLinks':
            provider.socialLinks.map((sm) => jsonEncode(sm.toJson())).toList(),
        'reviewList':
            provider.reviewList.map((rev) => jsonEncode(rev.toJson())).toList(),
        'status': 'pending',
      };

      // Create provider document in Appwrite database.
      await databases.createDocument(
        databaseId: _database,
        collectionId: _providerCollection,
        documentId: response.$id,
        data: dataToSend,
      );
      return;
    } catch (e) {
      throw AuthException(
          AuthException.handleError(e), 'provider_signup_error');
    }
  }

  Future<ServiceProvider> getProvider(String providerId) async {
    try {
      final document = await databases.getDocument(
        databaseId: _database,
        collectionId: _providerCollection,
        documentId: providerId,
      );
      return ServiceProvider.fromJson(document.data);
    } catch (e) {
      throw Exception('Failed to get provider: ${e.toString()}');
    }
  }

  Future<ServiceProvider> updateProvider({
    required String providerId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final document = await databases.updateDocument(
        databaseId: _database,
        collectionId: _providerCollection,
        documentId: providerId,
        data: updates,
      );

      // Send notification for profile update
      await _notificationService.createNotification(
        userId: providerId,
        type: NotificationType.profile,
        title: 'Profile Updated',
        message: 'Your provider profile has been updated successfully',
      );

      return ServiceProvider.fromJson(document.data);
    } catch (e) {
      throw Exception('Failed to update provider: ${e.toString()}');
    }
  }

  // File Upload Helpers
  Future<String> uploadFileforURL(String path, String folder) async {
    try {
      final uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.split('/').last}';
      InputFile inputFile =
          InputFile.fromPath(path: path, filename: uniqueFileName);

      final uploadedFile = await storage.createFile(
        bucketId: _generalStorageBucket,
        fileId: ID.unique(),
        file: inputFile,
      );

      final imageUrl =
          '${ApiConstants.endPoint}/storage/buckets/$_generalStorageBucket/files/${uploadedFile.$id}/view?project=${ApiConstants.projectId}';

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload file: ${e.toString()}');
    }
  }

  // Provider Authentication
  Future<Map<String, dynamic>> loginProvider({
    required String email,
    required String password,
  }) async {
    try {
      final session = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      final provider = await databases.getDocument(
        databaseId: _database,
        collectionId: _providerCollection,
        documentId: session.userId,
      );

      switch (provider.data['status']) {
        case 'pending':
          await account.deleteSession(sessionId: 'current');
          throw AuthException(
            'Your account is pending approval from admin.',
            'pending_approval'
          );

        case 'rejected':
          await account.deleteSession(sessionId: 'current');
          throw AuthException(
            'Your Profile  has been rejected.',
            'account_rejected'
          );

        default:
          return provider.data;
      }
    } catch (e) {
      throw AuthException(AuthException.handleError(e), 'provider_login_error');
    }
  }

  Future<void> logoutProvider() async {
    try {
      await account.deleteSession(sessionId: 'current');
    } catch (e) {
      throw AuthException('Failed to logout', 'provider_logout_error');
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

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final currentUser = await account.get();
      final provider = await databases.getDocument(
        databaseId: _database,
        collectionId: _providerCollection,
        documentId: currentUser.$id,
      );

      switch (provider.data['status']) {
        case 'pending':
          await account.deleteSession(sessionId: 'current');
          throw AuthException(
              'Your account is pending approval.', 'not_approved');

        case 'rejected':
          await account.deleteSession(sessionId: 'current');
          throw AuthException(
              'Your account has been rejected.', 'not_approved');

        default:
      }

      return provider.data;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<void> submitReview(String providerId, Review review) async {
    try {
      // Get current provider data
      final provider = await getProvider(providerId);

      // Calculate new rating
      final totalRatingPoints =
          (provider.rating * provider.reviewCount) + review.rating;
      final newReviewCount = provider.reviewCount + 1;
      final newRating = totalRatingPoints / newReviewCount;

      // Update provider document
      final updates = {
        'rating': newRating,
        'reviewCount': newReviewCount,
        'reviewList': [
          ...provider.reviewList.map((r) => jsonEncode(r.toJson())),
          jsonEncode(review.toJson()),
        ],
      };

      await databases.updateDocument(
        databaseId: _database,
        collectionId: _providerCollection,
        documentId: providerId,
        data: updates,
      );

      // Send notification to provider about new review
      await _notificationService.createNotification(
        userId: providerId,
        type: NotificationType.profile,
        title: 'New Review Received',
        message: 'You received a ${review.rating}-star review from ${review.userName}',
      );


    } catch (e) {
      throw Exception('Failed to submit review: ${e.toString()}');
    }
  }
}
