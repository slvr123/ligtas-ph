/*import 'package:flutter/material.dart';
import 'home_screen.dart';

class LocationSetupScreen extends StatefulWidget {
  const LocationSetupScreen({super.key});

  @override
  State<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends State<LocationSetupScreen> {
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _locationController.text = "Muntinlupa City, Metro Manila";
  }

  void _confirmLocation() {
    if (_locationController.text.isNotEmpty && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            location: _locationController.text,
            // Mock coordinates for Muntinlupa City
            latitude: 14.4081,
            longitude: 121.0415,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'Set Your Location',
                style: theme.textTheme.displayLarge?.copyWith(fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'This helps us provide accurate, location-specific alerts and information.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Enter City, Province',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.map_outlined),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _confirmLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  textStyle: theme.textTheme.labelLarge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Confirm Location'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:disaster_awareness_app/screens/user_service.dart';
import 'package:disaster_awareness_app/screens/home_screen.dart';

class LocationSetupScreen extends StatefulWidget {
  const LocationSetupScreen({super.key});

  @override
  State<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends State<LocationSetupScreen> {
  final _locationController = TextEditingController();
  final UserService _userService = UserService();
  bool _isLoading = false;
  
  // Default coordinates for common Philippine cities
  final Map<String, Map<String, double>> _cityCoordinates = {
    'muntinlupa': {'lat': 14.4081, 'lng': 121.0415},
    'pasay': {'lat': 14.5378, 'lng': 121.0014},
    'makati': {'lat': 14.5547, 'lng': 121.0244},
    'quezon': {'lat': 14.6760, 'lng': 121.0437},
    'manila': {'lat': 14.5995, 'lng': 120.9842},
    'cebu': {'lat': 10.3157, 'lng': 123.8854},
    'davao': {'lat': 7.1907, 'lng': 125.4553},
  };

  double _latitude = 14.4081;  // Default to Muntinlupa
  double _longitude = 121.0415;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  // Load saved location from Firebase
  Future<void> _loadSavedLocation() async {
    try {
      final savedLocation = await _userService.getUserLocation();
      if (savedLocation != null && mounted) {
        setState(() {
          _locationController.text = savedLocation['location'];
          _latitude = savedLocation['latitude'];
          _longitude = savedLocation['longitude'];
        });
      } else {
        // Set default location
        _locationController.text = "Muntinlupa City, Metro Manila";
      }
    } catch (e) {
      print('Error loading saved location: $e');
      // Set default location on error
      _locationController.text = "Muntinlupa City, Metro Manila";
    }
  }

  // Get coordinates for the location
  void _getCoordinatesForLocation(String location) {
    String locationLower = location.toLowerCase();
    
    // Check if any city name is in the location string
    for (var entry in _cityCoordinates.entries) {
      if (locationLower.contains(entry.key)) {
        _latitude = entry.value['lat']!;
        _longitude = entry.value['lng']!;
        return;
      }
    }
    
    // If no match found, keep current coordinates
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';
        if (place.locality != null && place.locality!.isNotEmpty) {
          address = place.locality!;
        }
        if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
          address += address.isEmpty ? place.subAdministrativeArea! : ', ${place.subAdministrativeArea}';
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          address += address.isEmpty ? place.administrativeArea! : ', ${place.administrativeArea}';
        }

        setState(() {
          _locationController.text = address.isEmpty ? 'Current Location (GPS)' : address;
          _latitude = position.latitude;
          _longitude = position.longitude;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location found: ${_locationController.text}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmLocation() async {
    if (_locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a location'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get coordinates for the entered location
      _getCoordinatesForLocation(_locationController.text);

      // Save location to Firebase
      await _userService.saveUserLocation(
        location: _locationController.text,
        latitude: _latitude,
        longitude: _longitude,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              location: _locationController.text,
              latitude: _latitude,
              longitude: _longitude,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'Set Your Location',
                style: theme.textTheme.displayLarge?.copyWith(fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'This helps us provide accurate, location-specific alerts and information.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Enter City, Province',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.map_outlined),
                ),
              ),
              const SizedBox(height: 16),
              
              // GPS Location Button
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _useCurrentLocation,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(_isLoading ? 'Getting location...' : 'Use Current Location'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Confirm Button
              ElevatedButton(
                onPressed: _isLoading ? null : _confirmLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  textStyle: theme.textTheme.labelLarge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Confirm Location'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}