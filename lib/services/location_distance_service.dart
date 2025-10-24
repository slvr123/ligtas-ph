import 'dart:math';

class LocationDistanceService {
  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in kilometers
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371;

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadiusKm * c;

    return distance;
  }

  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Filter posts by distance from user location
  /// Returns posts sorted by distance (closest first)
  static List<T> filterByDistance<T>({
    required List<T> items,
    required double userLat,
    required double userLon,
    required double Function(T) getItemLat,
    required double Function(T) getItemLon,
    required double maxDistanceKm,
  }) {
    return items
        .where((item) {
          final distance = calculateDistance(
            userLat,
            userLon,
            getItemLat(item),
            getItemLon(item),
          );
          return distance <= maxDistanceKm;
        })
        .toList()
        ..sort((a, b) {
          final distanceA = calculateDistance(
            userLat,
            userLon,
            getItemLat(a),
            getItemLon(a),
          );
          final distanceB = calculateDistance(
            userLat,
            userLon,
            getItemLat(b),
            getItemLon(b),
          );
          return distanceA.compareTo(distanceB);
        });
  }

  /// Sort items by distance from user location
  static List<T> sortByDistance<T>({
    required List<T> items,
    required double userLat,
    required double userLon,
    required double Function(T) getItemLat,
    required double Function(T) getItemLon,
  }) {
    return items
        .toList()
        ..sort((a, b) {
          final distanceA = calculateDistance(
            userLat,
            userLon,
            getItemLat(a),
            getItemLon(a),
          );
          final distanceB = calculateDistance(
            userLat,
            userLon,
            getItemLat(b),
            getItemLon(b),
          );
          return distanceA.compareTo(distanceB);
        });
  }

  /// Get distance string for display
  static String getDistanceString(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)}m away';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)}km away';
    } else {
      return '${distanceKm.toStringAsFixed(0)}km away';
    }
  }
}