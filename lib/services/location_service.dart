import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:appwrite/appwrite.dart';
import 'package:healthcare/constants/api_constants.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:healthcare/models/provider_location_status.dart';

class LocationService {
  final loc.Location _location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;
  final Client client = Client();
  late Databases databases;
  late Realtime realtime;
  static const String _database = '67e6393a0009ccfe982e';
  static const String _collectionId = '6859399e0030090fb711';

  LocationService() {
    _init();
    _location.enableBackgroundMode(enable: true);
  }

  void _init() {
    client
        .setEndpoint(ApiConstants.endPoint)
        .setProject(ApiConstants.projectId)
        .setSelfSigned(status: true);

    databases = Databases(client);
    realtime = Realtime(client);
  }

  Future<void> requestPermission() async {
    var status = await perm.Permission.location.request();
    if (status.isGranted) {
      print('Permission granted');
    } else if (status.isDenied) {
      print("Permission denied. Please grant location access.");
    } else if (status.isPermanentlyDenied) {
      perm.openAppSettings();
    }
  }

  Future<bool> checkPermission() async {
    var status = await perm.Permission.location.status;
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      // Request permission if it is denied
      await requestPermission();
      print("Permission denied. Please grant location access.");
      return false;
    } else if (status.isPermanentlyDenied) {
      perm.openAppSettings();
      return false;
    }
    return false;
  }

  // Start listening for location changes
  Future<void> startListening(String providerId) async {
    _locationSubscription = _location.onLocationChanged.handleError((onError) {
      print("Error listening to location changes: $onError");
      _locationSubscription?.cancel();
      _locationSubscription = null;
    }).listen((loc.LocationData currentLocation) async {
      try {
        final now = DateTime.now();
        await databases.updateDocument(
          databaseId: _database,
          collectionId: _collectionId,
          documentId: providerId,
          data: {
            'latitude': currentLocation.latitude,
            'longitude': currentLocation.longitude,
            'lastUpdated': now.toIso8601String(),
            'isOnline': true,
          },
        );
      } catch (e) {
        if (e is AppwriteException && e.code == 404) {
          await databases.createDocument(
            databaseId: _database,
            collectionId: _collectionId,
            documentId: providerId,
            data: {
              'latitude': currentLocation.latitude,
              'longitude': currentLocation.longitude,
              'lastUpdated': DateTime.now().toIso8601String(),
              'isOnline': true,
            },
          );
        } else {
          print("Error updating location: $e");
          debugPrint('Error updating location: $e');
        }
      }
    });
  }

  void stopListening(String providerId) async {
    final loc.LocationData locationResult = await _location.getLocation();
    try {
      await databases.updateDocument(
        databaseId: _database,
        collectionId: _collectionId,
        documentId: providerId,
        data: {
          'latitude': locationResult.latitude,
          'longitude': locationResult.longitude,
          'lastUpdated': DateTime.now().toIso8601String(),
          'isOnline': false,
        },
      );
    } catch (e) {
      //show error of last location update before going offline
    }
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  Future<void> subscribeToRealTimeLocation(String providerId) async {
    final channel =
        'databases.$_database.collections.$_collectionId.documents.$providerId';
    final subscription = realtime.subscribe([channel]);
    subscription.stream.listen((event) {
      final data = event.payload;
      print('Real-time location update: $data');
      // Handle the real-time location update
    });
  }

  Stream<ProviderLocationStatus> getProviderLocationStatusStream(
      String providerId) {
    final channel =
        'databases.$_database.collections.$_collectionId.documents.$providerId';
    final subscription = realtime.subscribe([channel]);

    return subscription.stream.map((response) {
      try {
        final data = response.payload;
        if (data != null) {
          LatLng? location;
          if (data['latitude'] != null && data['longitude'] != null) {
            location = LatLng(
              data['latitude'].toDouble(),
              data['longitude'].toDouble(),
            );
          }

          final lastUpdated = DateTime.parse(
              data['lastUpdated'] ?? DateTime.now().toIso8601String());
          final isOnline = (data['isOnline'] ?? false) &&
              DateTime.now().difference(lastUpdated).inMinutes < 2;

          return ProviderLocationStatus(
            location: location,
            isOnline: isOnline,
            lastUpdated: lastUpdated,
          );
        }
        return ProviderLocationStatus(
          location: null,
          isOnline: false,
          lastUpdated: DateTime.now(),
        );
      } catch (e) {
        debugPrint('Error parsing location status: $e');
        return ProviderLocationStatus(
          location: null,
          isOnline: false,
          lastUpdated: DateTime.now(),
        );
      }
    });
  }
}
