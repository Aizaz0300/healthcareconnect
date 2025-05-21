import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import '../models/service_provider.dart';
import '../constants/api_constants.dart';
import '../utils/auth_exceptions.dart';


class AppwriteProviderService {
  Client client = Client();
  late Account account;
  late Databases databases;
  late Storage storage;
  
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
      'socialLinks': provider.socialLinks
          .map((sm) => jsonEncode(sm.toJson()))
          .toList(),
      'reviewList': provider.reviewList
          .map((rev) => jsonEncode(rev.toJson()))
          .toList(),
      'status': 'pending', // pending, approved, rejected
      'id': response.$id,
    };

    // Create provider document in Appwrite database.
    final document = await databases.createDocument(
      databaseId: _database,
      collectionId: _providerCollection,
      documentId: response.$id,
      data: dataToSend,
    );
    return;
    } catch (e) {
      throw AuthException(AuthException.handleError(e), 'provider_signup_error');
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

      return ServiceProvider.fromJson(document.data);
    } catch (e) {
      throw Exception('Failed to update provider: ${e.toString()}');
    }
  }

  // File Upload Helpers
  Future<String> uploadFileforURL(String path, String folder) async {
    try {
      final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_${path.split('/').last}';
      InputFile inputFile = InputFile.fromPath(path: path, filename: uniqueFileName);


      final uploadedFile = await storage.createFile(
        bucketId: _generalStorageBucket,
        fileId: ID.unique(),
        file: inputFile,
      );

      final imageUrl = '${ApiConstants.endPoint}/storage/buckets/$_generalStorageBucket/files/${uploadedFile.$id}/view?project=${ApiConstants.projectId}';

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
          throw AuthException('Your account is pending approval.', 'not_approved');

        case 'rejected':
          await account.deleteSession(sessionId: 'current');
          throw AuthException('Your account has been rejected.', 'not_approved');
 
        default:
      }

      return provider.data;
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

  // Provider Status Management
  Future<void> updateProviderStatus({
    required String providerId,
    required String status,
    String? reason,
  }) async {
    try {
      await databases.updateDocument(
        databaseId: _database,
        collectionId: _providerCollection,
        documentId: providerId,
        data: {
          'status': status,
          'statusReason': reason,
          'statusUpdatedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to update provider status: ${e.toString()}');
    }
  }

  // Provider Search and Filtering
  Future<List<ServiceProvider>> searchProviders({
    String? service,
    String? location,
    double? rating,
  }) async {
    try {
      List<String> queries = [
        Query.equal('status', 'approved'),
      ];

      if (service != null) {
        queries.add(Query.search('services', service));
      }
      if (location != null) {
        queries.add(Query.search('address', location));
      }
      if (rating != null) {
        queries.add(Query.greaterThanEqual('rating', rating));
      }

      final response = await databases.listDocuments(
        databaseId: _database,
        collectionId: _providerCollection,
        queries: queries,
      );

      return response.documents
          .map((doc) => ServiceProvider.fromJson(doc.data))
          .toList();
    } catch (e) {
      throw Exception('Failed to search providers: ${e.toString()}');
    }
  }

  // Availability Management

  // Stats and Analytics
  Future<Map<String, dynamic>> getProviderStats(String providerId) async {
    try {
      final document = await databases.getDocument(
        databaseId: _database,
        collectionId: _providerCollection,
        documentId: providerId,
      );

      return {
        'rating': document.data['rating'] ?? 0.0,
        'reviewCount': document.data['reviewCount'] ?? 0,
        'completedServices': document.data['completedServices'] ?? 0,
        // Add more stats as needed
      };
    } catch (e) {
      throw Exception('Failed to get provider stats: ${e.toString()}');
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
          throw AuthException('Your account is pending approval.', 'not_approved');

        case 'rejected':
          await account.deleteSession(sessionId: 'current');
          throw AuthException('Your account has been rejected.', 'not_approved');
 
        default:
      }

      return provider.data;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
}