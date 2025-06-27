import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:healthcare/services/location_service.dart';
import 'package:healthcare/models/provider_location_status.dart';

class ProviderLocationMap extends StatefulWidget {
  final String providerId;


  const ProviderLocationMap({
    Key? key,
    required this.providerId,
  }) : super(key: key);

  @override
  State<ProviderLocationMap> createState() => _ProviderLocationMapState();
}

class _ProviderLocationMapState extends State<ProviderLocationMap> {
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _subscribeToLocationUpdates();
  }

  void _updateMarker(LatLng position, bool isOnline) {
    setState(() {
      _markers = {
        Marker(
          markerId: MarkerId(widget.providerId),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      };
    });
  }

  void _subscribeToLocationUpdates() {
    _locationService.getProviderLocationStatusStream(widget.providerId).listen(
      (status) {
        if (status.location != null && mounted && _mapController != null) {
          _updateMarker(status.location!, status.isOnline);
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(status.location!),
          );
        }
      },
      onError: (error) {
        debugPrint('Error receiving location updates: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 200,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(31.44678817696382, 74.26772867130585), 
              zoom: 15,
            ),
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: StreamBuilder<ProviderLocationStatus>(
            stream: _locationService.getProviderLocationStatusStream(widget.providerId),
            builder: (context, snapshot) {
              final isOnline = snapshot.data?.isOnline ?? false;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isOnline ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isOnline ? Colors.green : Colors.grey,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isOnline 
                                ? Colors.green.withOpacity(0.4) 
                                : Colors.grey.withOpacity(0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: isOnline ? Colors.green.shade800 : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
