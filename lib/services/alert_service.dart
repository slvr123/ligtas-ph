import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class Alert {
  final String id;
  final String title;
  final String description;
  final String level; // SEVERE, MODERATE, WARNING, INFO
  final String type; // Typhoon, Rainfall, Earthquake, Flood, Fire, Air Quality, etc.
  final List<String> affectedAreas;
  final DateTime issuedTime;
  final DateTime expiryTime;
  final double? latitude;
  final double? longitude;
  final String source; // OpenWeatherMap, USGS, etc.

  Alert({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.type,
    required this.affectedAreas,
    required this.issuedTime,
    required this.expiryTime,
    this.latitude,
    this.longitude,
    required this.source,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isBefore(expiryTime) && now.isAfter(issuedTime);
  }

  bool affectsLocation(String userLocation) {
    final userLocationLower = userLocation.toLowerCase();
    return affectedAreas.any((area) => area.toLowerCase().contains(userLocationLower) || userLocationLower.contains(area.toLowerCase()));
  }
}

class AlertDebugInfo {
  final String source;
  final int totalFetched;
  final int activeAlerts;
  final String status; // 'SUCCESS', 'ERROR', 'NO_DATA'
  final String? errorMessage;
  final List<String>? sampleAlerts;

  AlertDebugInfo({
    required this.source,
    required this.totalFetched,
    required this.activeAlerts,
    required this.status,
    this.errorMessage,
    this.sampleAlerts,
  });
}

class AlertService {
  static const String _openWeatherMapApiKey = '2bc2585499379578ebb3c47836349c1c';
  static const String _usgsEarthquakeUrl = 'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson';
  
  // Debug tracking
  final List<AlertDebugInfo> _debugInfo = [];

  List<AlertDebugInfo> get debugInfo => _debugInfo;

  void clearDebugInfo() {
    _debugInfo.clear();
  }

  // Philippine cities with coordinates for alert checking
  static const Map<String, Map<String, double>> _philippineCities = {
    'manila': {'lat': 14.5995, 'lng': 120.9842},
    'quezon city': {'lat': 14.6760, 'lng': 121.0437},
    'cebu': {'lat': 10.3157, 'lng': 123.8854},
    'davao': {'lat': 7.1907, 'lng': 125.4553},
    'antipolo': {'lat': 14.5881, 'lng': 121.1714},
    'makati': {'lat': 14.5547, 'lng': 121.0244},
    'pasay': {'lat': 14.5378, 'lng': 121.0014},
    'taguig': {'lat': 14.5794, 'lng': 121.0670},
    'muntinlupa': {'lat': 14.4081, 'lng': 121.0415},
    'cavite': {'lat': 14.4832, 'lng': 120.9060},
  };

  /// Fetch all alerts from multiple sources
  Future<List<Alert>> fetchAlerts() async {
    try {
      final alerts = <Alert>[];
      clearDebugInfo();

      // Fetch weather alerts
      try {
        final weatherAlerts = await _fetchWeatherAlerts();
        alerts.addAll(weatherAlerts);
      } catch (e) {
        print('❌ Error fetching weather alerts: $e');
        _debugInfo.add(AlertDebugInfo(
          source: 'OpenWeatherMap',
          totalFetched: 0,
          activeAlerts: 0,
          status: 'ERROR',
          errorMessage: e.toString(),
        ));
      }

      // Fetch earthquake alerts
      try {
        final earthquakeAlerts = await _fetchEarthquakeAlerts();
        alerts.addAll(earthquakeAlerts);
      } catch (e) {
        print('❌ Error fetching earthquake alerts: $e');
        _debugInfo.add(AlertDebugInfo(
          source: 'USGS Earthquake',
          totalFetched: 0,
          activeAlerts: 0,
          status: 'ERROR',
          errorMessage: e.toString(),
        ));
      }

      // Fetch air quality alerts
      try {
        final airQualityAlerts = await _fetchAirQualityAlerts();
        alerts.addAll(airQualityAlerts);
      } catch (e) {
        print('❌ Error fetching air quality alerts: $e');
        _debugInfo.add(AlertDebugInfo(
          source: 'OpenWeatherMap Air Quality',
          totalFetched: 0,
          activeAlerts: 0,
          status: 'ERROR',
          errorMessage: e.toString(),
        ));
      }

      // Filter only active alerts
      final activeAlerts = alerts.where((alert) => alert.isActive).toList();
      print('📊 Total alerts fetched: ${alerts.length}, Active: ${activeAlerts.length}');
      
      return activeAlerts;
    } catch (e) {
      print('❌ Error fetching alerts: $e');
      return [];
    }
  }

  /// Fetch weather alerts from OpenWeatherMap
  Future<List<Alert>> _fetchWeatherAlerts() async {
    final alerts = <Alert>[];

    for (var entry in _philippineCities.entries) {
      try {
        final cityAlerts = await _fetchWeatherAlertsForCity(
          entry.key,
          entry.value['lat']!,
          entry.value['lng']!,
        );
        alerts.addAll(cityAlerts);
      } catch (e) {
        print('❌ Error fetching weather alerts for ${entry.key}: $e');
      }
    }

    _debugInfo.add(AlertDebugInfo(
      source: 'OpenWeatherMap Weather',
      totalFetched: alerts.length,
      activeAlerts: alerts.where((a) => a.isActive).length,
      status: alerts.isEmpty ? 'NO_DATA' : 'SUCCESS',
      sampleAlerts: alerts.take(3).map((a) => a.title).toList(),
    ));

    return alerts;
  }

  /// Fetch weather alerts for specific city
  Future<List<Alert>> _fetchWeatherAlertsForCity(
    String cityName,
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$_openWeatherMapApiKey&units=metric',
        ),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'LigatsPH-DisasterApp/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final alerts = <Alert>[];

        final weather = data['weather'] as List<dynamic>?;
        final wind = data['wind'] as Map<String, dynamic>?;
        final rain = data['rain'] as Map<String, dynamic>?;

        if (weather != null && weather.isNotEmpty) {
          final weatherMain = weather[0]['main'].toString();
          final weatherDesc = weather[0]['description'].toString();

          String alertLevel = 'INFO';
          String alertType = 'Weather';
          String alertTitle = 'Weather Alert';
          String alertDescription = '';

          if (weatherMain.contains('Thunderstorm')) {
            alertLevel = 'SEVERE';
            alertType = 'Thunderstorm';
            alertTitle = 'Thunderstorm Warning';
            alertDescription = 'Severe thunderstorms with heavy rainfall expected in $cityName.';
          } else if (weatherMain.contains('Rain')) {
            final rainVolume = rain?['1h'] ?? 0.0;
            if (rainVolume > 30) {
              alertLevel = 'SEVERE';
              alertType = 'Rainfall';
              alertTitle = 'Red Rainfall Warning';
              alertDescription = 'Intense rainfall (${rainVolume.toStringAsFixed(1)}mm/1hr) is affecting $cityName. Serious flooding is expected.';
            } else if (rainVolume > 15) {
              alertLevel = 'MODERATE';
              alertType = 'Rainfall';
              alertTitle = 'Orange Rainfall Warning';
              alertDescription = 'Heavy rainfall (${rainVolume.toStringAsFixed(1)}mm/1hr) is affecting $cityName. Flooding is threatening.';
            } else {
              alertLevel = 'WARNING';
              alertType = 'Rainfall';
              alertTitle = 'Yellow Rainfall Alert';
              alertDescription = 'Light to moderate rainfall expected in $cityName.';
            }
          } else if (weatherMain.contains('Tornado') || weatherMain.contains('Squall')) {
            alertLevel = 'SEVERE';
            alertType = 'Typhoon';
            alertTitle = 'Typhoon/Squall Warning';
            alertDescription = 'Severe winds and potential tornado activity in $cityName. Take shelter immediately.';
          } else if (weatherMain.contains('Windy') || (wind != null && (wind['speed'] ?? 0) > 50)) {
            final windSpeed = wind?['speed'] ?? 0;
            if (windSpeed > 80) {
              alertLevel = 'SEVERE';
              alertType = 'Strong Winds';
              alertTitle = 'Typhoon Signal Alert';
              alertDescription = 'Destructive winds (${windSpeed.toStringAsFixed(1)} km/h) detected in $cityName. Secure all loose objects.';
            } else if (windSpeed > 60) {
              alertLevel = 'MODERATE';
              alertType = 'Strong Winds';
              alertTitle = 'Strong Wind Warning';
              alertDescription = 'Strong winds (${windSpeed.toStringAsFixed(1)} km/h) expected in $cityName.';
            }
          }

          if (alertLevel != 'INFO') {
            final alert = Alert(
              id: '${cityName}_weather_${DateTime.now().millisecondsSinceEpoch}',
              title: alertTitle,
              description: alertDescription,
              level: alertLevel,
              type: alertType,
              affectedAreas: [cityName],
              issuedTime: DateTime.now(),
              expiryTime: DateTime.now().add(const Duration(hours: 6)),
              latitude: latitude,
              longitude: longitude,
              source: 'OpenWeatherMap',
            );
            alerts.add(alert);
          }
        }

        return alerts;
      } else {
        print('🔴 OpenWeatherMap API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('🔴 Error fetching weather alerts for $cityName: $e');
      return [];
    }
  }

  /// Fetch earthquake alerts from USGS
  Future<List<Alert>> _fetchEarthquakeAlerts() async {
    try {
      final response = await http.get(
        Uri.parse(_usgsEarthquakeUrl),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'LigatsPH-DisasterApp/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List<dynamic>? ?? [];
        final alerts = <Alert>[];

        print('🌍 USGS returned ${features.length} earthquakes total');

        // Filter earthquakes near Philippines with magnitude > 4.0
        for (var feature in features) {
          try {
            final properties = feature['properties'] as Map<String, dynamic>;
            final geometry = feature['geometry'] as Map<String, dynamic>;
            final coordinates = geometry['coordinates'] as List<dynamic>;

            final magnitude = properties['mag'] as num? ?? 0;
            final place = properties['place'] as String? ?? 'Unknown';
            final time = properties['time'] as int? ?? 0;

            // Convert to double safely - handles both int and double
            final longitude = (coordinates[0] as num).toDouble();
            final latitude = (coordinates[1] as num).toDouble();

            // Check if earthquake is near Philippines (roughly between 4-21N, 116-127E)
            final isNearPhilippines = latitude >= 4.5 && latitude <= 21.0 && longitude >= 116.0 && longitude <= 127.0;

            if (isNearPhilippines && magnitude >= 4.0) {
              print('🔴 Found earthquake near PH: Mag $magnitude at $latitude, $longitude');
              String alertLevel = 'INFO';
              String alertTitle = 'Earthquake Alert';

              if (magnitude >= 7.0) {
                alertLevel = 'SEVERE';
                alertTitle = 'Major Earthquake - SEVERE';
              } else if (magnitude >= 6.0) {
                alertLevel = 'SEVERE';
                alertTitle = 'Strong Earthquake - SEVERE';
              } else if (magnitude >= 5.0) {
                alertLevel = 'MODERATE';
                alertTitle = 'Moderate Earthquake';
              } else if (magnitude >= 4.0) {
                alertLevel = 'WARNING';
                alertTitle = 'Light Earthquake';
              }

              final alert = Alert(
                id: 'earthquake_${properties['code']}_${DateTime.now().millisecondsSinceEpoch}',
                title: alertTitle,
                description: 'Magnitude $magnitude earthquake detected ${place}. Tsunami threat: ${properties['tsunami'] == 1 ? "YES" : "No"}',
                level: alertLevel,
                type: 'Earthquake',
                affectedAreas: _getAffectedCities(latitude, longitude),
                issuedTime: DateTime.fromMillisecondsSinceEpoch(time),
                expiryTime: DateTime.fromMillisecondsSinceEpoch(time).add(const Duration(hours: 24)),
                latitude: latitude,
                longitude: longitude,
                source: 'USGS',
              );
              alerts.add(alert);
            }
          } catch (e) {
            print('❌ Error parsing earthquake data: $e');
          }
        }

        _debugInfo.add(AlertDebugInfo(
          source: 'USGS Earthquake',
          totalFetched: alerts.length,
          activeAlerts: alerts.where((a) => a.isActive).length,
          status: alerts.isEmpty ? 'NO_DATA' : 'SUCCESS',
          sampleAlerts: alerts.take(3).map((a) => a.title).toList(),
        ));

        return alerts;
      } else {
        print('🔴 USGS API error: ${response.statusCode}');
        _debugInfo.add(AlertDebugInfo(
          source: 'USGS Earthquake',
          totalFetched: 0,
          activeAlerts: 0,
          status: 'ERROR',
          errorMessage: 'HTTP ${response.statusCode}',
        ));
        return [];
      }
    } catch (e) {
      print('❌ Error fetching earthquake alerts: $e');
      _debugInfo.add(AlertDebugInfo(
        source: 'USGS Earthquake',
        totalFetched: 0,
        activeAlerts: 0,
        status: 'ERROR',
        errorMessage: e.toString(),
      ));
      return [];
    }
  }

  /// Fetch air quality alerts from OpenWeatherMap
  Future<List<Alert>> _fetchAirQualityAlerts() async {
    final alerts = <Alert>[];

    for (var entry in _philippineCities.entries) {
      try {
        final cityAlerts = await _fetchAirQualityForCity(
          entry.key,
          entry.value['lat']!,
          entry.value['lng']!,
        );
        alerts.addAll(cityAlerts);
      } catch (e) {
        print('❌ Error fetching air quality for ${entry.key}: $e');
      }
    }

    _debugInfo.add(AlertDebugInfo(
      source: 'OpenWeatherMap Air Quality',
      totalFetched: alerts.length,
      activeAlerts: alerts.where((a) => a.isActive).length,
      status: alerts.isEmpty ? 'NO_DATA' : 'SUCCESS',
      sampleAlerts: alerts.take(3).map((a) => a.title).toList(),
    ));

    return alerts;
  }

  /// Fetch air quality for specific city
  Future<List<Alert>> _fetchAirQualityForCity(
    String cityName,
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/air_pollution?lat=$latitude&lon=$longitude&appid=$_openWeatherMapApiKey',
        ),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'LigatsPH-DisasterApp/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final alerts = <Alert>[];

        final list = data['list'] as List<dynamic>?;
        if (list != null && list.isNotEmpty) {
          final current = list[0] as Map<String, dynamic>;
          final aqi = current['main']['aqi'] as int?;

          // AQI: 1=Good, 2=Fair, 3=Moderate, 4=Poor, 5=Very Poor
          String alertLevel = 'INFO';
          String alertTitle = 'Air Quality Good';
          String alertDescription = 'Air quality is good in $cityName.';

          if (aqi == 5) {
            alertLevel = 'SEVERE';
            alertTitle = 'Very Poor Air Quality - SEVERE';
            alertDescription = 'Very poor air quality in $cityName. Sensitive groups should avoid outdoor activities.';
          } else if (aqi == 4) {
            alertLevel = 'MODERATE';
            alertTitle = 'Poor Air Quality';
            alertDescription = 'Poor air quality in $cityName. People with respiratory issues should be cautious.';
          } else if (aqi == 3) {
            alertLevel = 'WARNING';
            alertTitle = 'Moderate Air Quality';
            alertDescription = 'Moderate air quality in $cityName. Unusually sensitive people should consider reducing outdoor activities.';
          } else if (aqi == 2) {
            alertLevel = 'INFO';
            alertTitle = 'Fair Air Quality';
            alertDescription = 'Fair air quality in $cityName.';
          }

          if (alertLevel != 'INFO') {
            final alert = Alert(
              id: '${cityName}_airquality_${DateTime.now().millisecondsSinceEpoch}',
              title: alertTitle,
              description: alertDescription,
              level: alertLevel,
              type: 'Air Quality',
              affectedAreas: [cityName],
              issuedTime: DateTime.now(),
              expiryTime: DateTime.now().add(const Duration(hours: 3)),
              latitude: latitude,
              longitude: longitude,
              source: 'OpenWeatherMap Air Pollution API',
            );
            alerts.add(alert);
          }
        }

        return alerts;
      } else {
        print('🔴 Air Pollution API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching air quality for $cityName: $e');
      return [];
    }
  }

  /// Get nearby cities based on coordinates
  List<String> _getAffectedCities(double lat, double lng) {
    final affected = <String>[];
    
    for (var entry in _philippineCities.entries) {
      final distance = _calculateDistance(
        lat,
        lng,
        entry.value['lat']!,
        entry.value['lng']!,
      );
      
      // Include cities within 100km
      if (distance <= 100) {
        affected.add(entry.key);
      }
    }
    
    return affected.isEmpty ? ['Philippines'] : affected;
  }

  /// Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double degrees) {
    return degrees * 3.14159265359 / 180;
  }

  /// Get alerts for specific location
  Future<List<Alert>> getAlertsForLocation(String userLocation) async {
    final allAlerts = await fetchAlerts();
    
    if (allAlerts.isEmpty) return [];
    
    return allAlerts.where((alert) => alert.affectsLocation(userLocation)).toList();
  }

  /// Get highest priority alert for location
  Future<Alert?> getHighestPriorityAlert(String userLocation) async {
    final alerts = await getAlertsForLocation(userLocation);

    if (alerts.isEmpty) return null;

    const severityOrder = {'SEVERE': 0, 'MODERATE': 1, 'WARNING': 2, 'INFO': 3};

    alerts.sort((a, b) {
      final aOrder = severityOrder[a.level] ?? 4;
      final bOrder = severityOrder[b.level] ?? 4;
      return aOrder.compareTo(bOrder);
    });

    return alerts.first;
  }

  /// Stream alerts for real-time updates
  Stream<List<Alert>> streamAlertsForLocation(String userLocation) async* {
    while (true) {
      try {
        final alerts = await getAlertsForLocation(userLocation);
        yield alerts;
        await Future.delayed(const Duration(minutes: 10));
      } catch (e) {
        print('❌ Error in stream: $e');
        yield [];
        await Future.delayed(const Duration(minutes: 10));
      }
    }
  }
}