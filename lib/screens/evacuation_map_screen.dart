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

  // ⭐ Store all centers and the currently selected one
  List<EvacuationCenter> _allSortedCenters = [];
  EvacuationCenter? _selectedCenter; // This REPLACES _nearestCenter

  bool _isLoading = true;
  String _error = '';

  // ⭐ Markers are now built inside the build method, not stored in state
  // List<Marker> _markers = []; // REMOVED

  @override
  void initState() {
    super.initState();
    _findEvacuationCenters(); // Renamed function
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

  // Fetch, calculate, and sort centers
  Future<void> _findEvacuationCenters() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = '';
      // _markers = []; // No longer needed here
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

      // 3. ⭐ Create flutter_map Markers
      //    We don't create markers here anymore. We just set the state.

      // 4. Update state
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _allSortedCenters = centers; // ⭐ Store the full sorted list
        _selectedCenter = nearest; // ⭐ Set the nearest as the default selected
        // _markers = mapMarkers; // We build markers in the build method
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

  // ⭐ New function when a center is tapped (from map or list)
  void _onCenterSelected(EvacuationCenter center) {
    setState(() {
      _selectedCenter = center; // Update the selected center
    });
    // Move map to the selected center
    _mapController.move(center.coordinates, 15.0); // Zoom in a bit more
  }

  // ⭐ New function to show the list in a bottom sheet
  void _showCentersList() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow sheet to take partial height
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Use DraggableScrollableSheet for a nice scrolling experience
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5, // Start at half screen
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (BuildContext context, ScrollController scrollController) {
            return Column(
              children: [
                // Handle to show it's draggable
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Text(
                  "All Centers (${_allSortedCenters.length})",
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                // The scrollable list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController, // Use the sheet's controller
                    itemCount: _allSortedCenters.length,
                    itemBuilder: (context, index) {
                      final center = _allSortedCenters[index];
                      final distanceKm =
                          (center.distanceInMeters / 1000).toStringAsFixed(1);
                      final bool isSelected = center.id == _selectedCenter?.id;
                      final bool isNearest = index == 0; // Since list is sorted

                      return ListTile(
                        leading: Icon(
                            isNearest
                                ? Icons.star_rounded // Special icon for nearest
                                : Icons.gite_rounded,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant),
                        title: Text(center.name,
                            style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : null)),
                        subtitle: Text(
                          center.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text("$distanceKm km"),
                        onTap: () {
                          _onCenterSelected(center); // Select the center
                          Navigator.pop(context); // Close the bottom sheet
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ⭐ New function to build markers dynamically based on state
  List<Marker> _buildMarkers() {
    List<Marker> mapMarkers = [];
    final userPosition =
        latlong.LatLng(widget.userLatitude, widget.userLongitude);

    // Get ID of nearest center (first in the sorted list)
    final String? nearestCenterId =
        _allSortedCenters.isNotEmpty ? _allSortedCenters.first.id : null;

    // Add User Marker
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

    // Add Center Markers
    for (var center in _allSortedCenters) {
      final bool isNearest = center.id == nearestCenterId;
      final bool isSelected = center.id == _selectedCenter?.id;

      // Determine color: Nearest is green, others are red
      final Color iconColor =
          isNearest ? Colors.green.shade700 : Colors.red.shade700;

      mapMarkers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: center.coordinates,
          child: GestureDetector(
            onTap: () => _onCenterSelected(center),
            child: Tooltip(
              message:
                  "${center.name}\n${(center.distanceInMeters / 1000).toStringAsFixed(1)} km away",
              // ⭐ Use a Stack to add the blue indicator
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // The main pin icon
                  Icon(
                    Icons.gite_rounded,
                    color: iconColor,
                    size: 35.0,
                  ),
                  // ⭐ Add this blue circle indicator if selected
                  if (isSelected)
                    Container(
                      width: 45.0, // Slightly larger than the icon
                      height: 45.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueAccent.withOpacity(0.3),
                        border: Border.all(
                            color: Colors.blueAccent.shade100, width: 2.0),
                      ),
                    ),
                ],
              ),
            ),
          ),
          rotate: true,
        ),
      );
    }
    return mapMarkers;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ⭐ Build markers list here, so it rebuilds on setState
    final currentMarkers = _buildMarkers();

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
                    // ⭐ Use the dynamically built marker list
                    MarkerLayer(markers: currentMarkers),
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

                // ⭐ Show SELECTED center info at the bottom
                if (_selectedCenter != null && !_isLoading)
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  // ⭐ Show "NEAREST" only if it's the actual nearest
                                  _selectedCenter!.id ==
                                          _allSortedCenters.first.id
                                      ? 'NEAREST EVACUATION CENTER'
                                      : 'SELECTED CENTER',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold),
                                ),
                                // ⭐ Button to open the list
                                TextButton.icon(
                                  icon:
                                      const Icon(Icons.list_rounded, size: 20),
                                  label: Text(
                                      "Show All (${_allSortedCenters.length})"),
                                  style: TextButton.styleFrom(
                                    foregroundColor: theme.colorScheme.primary,
                                  ),
                                  onPressed: _showCentersList,
                                )
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedCenter!.name,
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(_selectedCenter!.distanceInMeters / 1000).toStringAsFixed(1)} km away • ${_selectedCenter!.address}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _launchDirections(
                                    _selectedCenter!.coordinates),
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
