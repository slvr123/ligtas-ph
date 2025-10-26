import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:disaster_awareness_app/widgets/screen_header.dart';
import 'package:url_launcher/url_launcher.dart'; // For launching directions
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'
    as latlong; // Use 'as' to avoid name conflicts

// Model for evacuation center
class EvacuationCenter {
  final String id;
  final String name;
  final String address;
  final String city;
  final latlong.LatLng coordinates; // Use latlong2 LatLng
  double distanceInMeters;

  EvacuationCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.coordinates,
    this.distanceInMeters = 0.0,
  });
}

class EvacuationMapScreen extends StatefulWidget {
  final double userLatitude;
  final double userLongitude;
  final String userCity; // To filter Firestore query

  const EvacuationMapScreen({
    super.key,
    required this.userLatitude,
    required this.userLongitude,
    required this.userCity,
  });

  @override
  State<EvacuationMapScreen> createState() => _EvacuationMapScreenState();
}

class _EvacuationMapScreenState extends State<EvacuationMapScreen> {
  final MapController _mapController = MapController();
  List<Marker> _markers = []; // Use flutter_map's Marker
  EvacuationCenter? _nearestCenter;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _findNearestEvacuationCenter();
  }

  // Helper to launch Google Maps directions
  Future<void> _launchDirections(latlong.LatLng destination) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&origin=${widget.userLatitude},${widget.userLongitude}&destination=${destination.latitude},${destination.longitude}';
    final Uri launchUri = Uri.parse(googleMapsUrl);

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Fetch, calculate, sort, and create markers
  Future<void> _findNearestEvacuationCenter() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = '';
      _markers = [];
    });

    try {
      final userPosition =
          latlong.LatLng(widget.userLatitude, widget.userLongitude);

      // 1. Fetch centers, filtering by city
      QuerySnapshot querySnapshot;
      try {
        querySnapshot = await FirebaseFirestore.instance
            .collection('evacuation_centers')
            .where('city', isEqualTo: widget.userCity)
            .get();
      } catch (e) {
        print("Error querying by city: $e. Fetching all centers as fallback.");
        querySnapshot = await FirebaseFirestore.instance
            .collection('evacuation_centers')
            .get();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Could not filter by ${widget.userCity}, showing all centers.')),
          );
        }
      }

      if (querySnapshot.docs.isEmpty) {
        print(
            "No centers found for ${widget.userCity}. Fetching all centers as fallback.");
        querySnapshot = await FirebaseFirestore.instance
            .collection('evacuation_centers')
            .get();

        if (querySnapshot.docs.isEmpty) {
          throw Exception(
              'No evacuation centers found in the database. Please add at least one.');
        }
      }

      List<EvacuationCenter> centers = [];
      EvacuationCenter? nearest;

      // 2. Process and calculate distances
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['coordinates'] is! GeoPoint) {
          print(
              "Skipping document ${doc.id}: 'coordinates' field is missing or not a GeoPoint.");
          continue;
        }

        final GeoPoint coordinates = data['coordinates'] as GeoPoint;
        final centerPosition =
            latlong.LatLng(coordinates.latitude, coordinates.longitude);

        final distance = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          centerPosition.latitude,
          centerPosition.longitude,
        );

        final center = EvacuationCenter(
          id: doc.id,
          name: data['name'] ?? 'Unknown Center',
          address: data['address'] ?? 'No address',
          city: data['city'] ?? 'Unknown City',
          coordinates: centerPosition,
          distanceInMeters: distance,
        );
        centers.add(center);

        if (nearest == null || distance < nearest.distanceInMeters) {
          nearest = center;
        }
      }
      centers.sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));

      // 3. Create flutter_map Markers
      List<Marker> mapMarkers = [];
      mapMarkers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: userPosition,
          child: const Tooltip(
            message: "Your Location",
            child: Icon(Icons.person_pin_circle,
                color: Colors.blueAccent, size: 40.0),
          ),
          rotate: true,
        ),
      );
      for (var center in centers) {
        final isNearest = (center.id == nearest?.id);
        mapMarkers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: center.coordinates,
            child: Tooltip(
              message:
                  "${center.name}\n${(center.distanceInMeters / 1000).toStringAsFixed(1)} km away",
              child: Icon(Icons.gite_rounded,
                  color:
                      isNearest ? Colors.green.shade700 : Colors.red.shade700,
                  size: 35.0),
            ),
            rotate: true,
          ),
        );
      }

      // 4. Update state
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _nearestCenter = nearest;
        _markers = mapMarkers;
      });

      // 5. Move map camera
      _mapController.move(userPosition, 14.0);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(
            title: 'Evacuation Map',
            subtitle: 'Nearest Safe Areas near ${widget.userCity}',
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: latlong.LatLng(
                        widget.userLatitude, widget.userLongitude),
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.example.my_clean_app', // Your package name
                    ),
                    MarkerLayer(markers: _markers),
                  ],
                ),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
                if (_error.isNotEmpty)
                  Center(
                    child: Container(
                      color: Colors.black.withOpacity(0.7),
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Error: $_error',
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (_nearestCenter != null && !_isLoading)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NEAREST EVACUATION CENTER',
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _nearestCenter!.name,
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(_nearestCenter!.distanceInMeters / 1000).toStringAsFixed(1)} km away • ${_nearestCenter!.address}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _launchDirections(
                                    _nearestCenter!.coordinates),
                                icon: const Icon(Icons.directions_outlined),
                                label:
                                    const Text('Get Directions (Google Maps)'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: FloatingActionButton.small(
                    heroTag: 'recenter_map',
                    onPressed: () {
                      _mapController.move(
                          latlong.LatLng(
                              widget.userLatitude, widget.userLongitude),
                          14.0);
                    },
                    child: const Icon(Icons.my_location),
                    backgroundColor: Colors.white.withOpacity(0.8),
                    foregroundColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
