import 'package:google_maps_flutter/google_maps_flutter.dart';

class ProviderLocationStatus {
  final LatLng? location;
  final bool isOnline;
  final DateTime lastUpdated;

  ProviderLocationStatus({
    this.location,
    required this.isOnline,
    required this.lastUpdated,
  });
}
