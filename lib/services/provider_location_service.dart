import 'package:appwrite/appwrite.dart';
import 'package:healthcare/constants/api_constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ProviderLocationService {
  Client client = Client();
  late Databases _databases;
  late Realtime _realtime;
  static const String _databaseId = '67e6393a0009ccfe982e';
  static const String _collectionId = 'providerLocation';

  ProviderLocationService() {
    _init();
  }

  void _init() {
    client
        .setEndpoint(ApiConstants.endPoint)
        .setProject(ApiConstants.projectId)
        .setSelfSigned(status: true);

    _databases = Databases(client);
    _realtime = Realtime(client);
  }

  Future<void> createProviderLocation(String providerId, LatLng location) async {
    try {
      await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: providerId,  // Using providerId as document ID
        data: {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'timestamp': DateTime.now().toIso8601String(),
          'isOnline': true,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProviderLocation(String providerId, LatLng location) async {
    try {
      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: providerId,
        data: {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // If document doesn't exist, create it
      if (e is AppwriteException && e.code == 404) {
        await createProviderLocation(providerId, location);
      } else {
        rethrow;
      }
    }
  }

  Future<void> setProviderOnlineStatus(String providerId, bool isOnline) async {
    try {
      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: providerId,
        data: {
          'isOnline': isOnline,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Stream<LatLng> getProviderLocationStream(String providerId) {
    final subscription = _realtime.subscribe([
      'databases.$_databaseId.collections.$_collectionId.documents.$providerId'
    ]);

    return subscription.stream.map((response) {
      final data = response.payload;
      return LatLng(
        double.parse(data['latitude'].toString()),
        double.parse(data['longitude'].toString()),
      );
    });
  }

  Future<LatLng?> getProviderCurrentLocation(String providerId) async {
    try {
      final response = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: providerId,
      );

      final data = response.data;
      return LatLng(
        double.parse(data['latitude'].toString()),
        double.parse(data['longitude'].toString()),
      );
    } catch (e) {
      return null;
    }
  }
}
