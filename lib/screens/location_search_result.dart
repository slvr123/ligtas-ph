class LocationSearchResult {
  final String name;
  final double latitude;
  final double longitude;
  final String displayName;

  LocationSearchResult({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.displayName,
  });

  factory LocationSearchResult.fromJson(Map<String, dynamic> json) {
    // Extract name from display_name or use address components
    String name = json['name'] ?? '';
    if (name.isEmpty && json['address'] != null) {
      final address = json['address'] as Map<String, dynamic>;
      name = address['city'] ?? 
             address['town'] ?? 
             address['village'] ?? 
             address['municipality'] ?? 
             'Location';
    }

    return LocationSearchResult(
      name: name,
      latitude: double.parse(json['lat'].toString()),
      longitude: double.parse(json['lon'].toString()),
      displayName: json['display_name'] ?? name,
    );
  }

  @override
  String toString() => displayName;
}