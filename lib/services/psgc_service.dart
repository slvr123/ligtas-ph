


class PhilippineLocation {
  final String name;
  final String code;
  final String type; // Region, Province, City, Municipality
  final double latitude;
  final double longitude;

  PhilippineLocation({
    required this.name,
    required this.code,
    required this.type,
    required this.latitude,
    required this.longitude,
  });

  factory PhilippineLocation.fromJson(Map<String, dynamic> json) {
    return PhilippineLocation(
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      type: json['type'] ?? '',
      latitude: (json['lat'] ?? 0).toDouble(),
      longitude: (json['lng'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'code': code,
    'type': type,
    'lat': latitude,
    'lng': longitude,
  };

  @override
  String toString() => '$name, $type';
}

class PSGCLocationService {
  static final PSGCLocationService _instance = PSGCLocationService._internal();
  
  late List<PhilippineLocation> _allLocations;
  bool _isInitialized = false;

  factory PSGCLocationService() {
    return _instance;
  }

  PSGCLocationService._internal();

  /// Initialize with PSGC data (call this once at app startup)
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _allLocations = _getPhilippineLocations();
      _isInitialized = true;
      print('PSGC data loaded: ${_allLocations.length} locations');
    } catch (e) {
      print('Error initializing PSGC: $e');
      _allLocations = [];
    }
  }

  /// Search locations by name
  List<PhilippineLocation> searchLocations(String query) {
    if (query.isEmpty || !_isInitialized) return [];

    final queryLower = query.toLowerCase();
    
    // Search in all locations
    final results = _allLocations
        .where((location) =>
            location.name.toLowerCase().contains(queryLower) ||
            location.code.toLowerCase().contains(queryLower))
        .toList();

    results.sort((a, b) {
      // Exact name match comes first
      final aExact = a.name.toLowerCase() == queryLower ? 0 : 1;
      final bExact = b.name.toLowerCase() == queryLower ? 0 : 1;
      if (aExact != bExact) return aExact.compareTo(bExact);

      // Starts with query comes next
      final aStarts = a.name.toLowerCase().startsWith(queryLower) ? 0 : 1;
      final bStarts = b.name.toLowerCase().startsWith(queryLower) ? 0 : 1;
      if (aStarts != bStarts) return aStarts.compareTo(bStarts);

      // Cities and municipalities before regions and provinces
      final typeOrder = {'City': 0, 'Municipality': 1, 'Province': 2, 'Region': 3};
      final aOrder = typeOrder[a.type] ?? 4;
      final bOrder = typeOrder[b.type] ?? 4;
      return aOrder.compareTo(bOrder);
    });

    return results.take(15).toList();
  }

  /// Get location by exact name
  PhilippineLocation? getLocationByName(String name) {
    try {
      return _allLocations.firstWhere(
        (location) => location.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get all data for reference
  List<PhilippineLocation> getAllLocations() => _allLocations;

  /// Hardcoded PSGC data for major Philippine cities and municipalities
  /// This is a sample - in production, you'd load from a JSON file or Firebase
  List<PhilippineLocation> _getPhilippineLocations() {
    return [
      // Metro Manila
      PhilippineLocation(name: 'Manila', code: '133752000', type: 'City', latitude: 14.5995, longitude: 120.9842),
      PhilippineLocation(name: 'Quezon City', code: '133752010', type: 'City', latitude: 14.6760, longitude: 121.0437),
      PhilippineLocation(name: 'Makati', code: '133752001', type: 'City', latitude: 14.5547, longitude: 121.0244),
      PhilippineLocation(name: 'Pasay', code: '133752002', type: 'City', latitude: 14.5378, longitude: 121.0014),
      PhilippineLocation(name: 'Taguig', code: '133752011', type: 'City', latitude: 14.5794, longitude: 121.0670),
      PhilippineLocation(name: 'Muntinlupa', code: '133752004', type: 'City', latitude: 14.4081, longitude: 121.0415),
      PhilippineLocation(name: 'Marikina', code: '133752003', type: 'City', latitude: 14.6496, longitude: 121.1782),
      PhilippineLocation(name: 'Las Piñas', code: '133752012', type: 'City', latitude: 14.3534, longitude: 120.9654),
      PhilippineLocation(name: 'Parañaque', code: '133752013', type: 'City', latitude: 14.3557, longitude: 121.0071),
      PhilippineLocation(name: 'Malabon', code: '133752005', type: 'City', latitude: 14.7686, longitude: 120.9369),
      PhilippineLocation(name: 'Caloocan', code: '133752006', type: 'City', latitude: 14.7298, longitude: 120.9575),
      PhilippineLocation(name: 'Valenzuela', code: '133752007', type: 'City', latitude: 14.7625, longitude: 120.9486),
      
      // Cavite
      PhilippineLocation(name: 'Cavite', code: '171900000', type: 'Province', latitude: 14.4832, longitude: 120.9060),
      PhilippineLocation(name: 'Kawit', code: '171904000', type: 'Municipality', latitude: 14.4386, longitude: 120.8597),
      PhilippineLocation(name: 'Rosario', code: '171917000', type: 'Municipality', latitude: 14.4853, longitude: 121.2081),
      PhilippineLocation(name: 'Tagaytay', code: '171920000', type: 'Municipality', latitude: 14.0886, longitude: 120.9634),
      PhilippineLocation(name: 'Dasmariñas', code: '171906000', type: 'Municipality', latitude: 14.3089, longitude: 120.9485),
      
      // Laguna
      PhilippineLocation(name: 'Laguna', code: '172000000', type: 'Province', latitude: 14.3134, longitude: 121.2276),
      PhilippineLocation(name: 'Calamba', code: '172003000', type: 'City', latitude: 14.1990, longitude: 121.1718),
      PhilippineLocation(name: 'San Pedro', code: '172011000', type: 'Municipality', latitude: 14.3589, longitude: 121.0156),
      PhilippineLocation(name: 'Biñan', code: '172002000', type: 'City', latitude: 14.3213, longitude: 121.0594),
      PhilippineLocation(name: 'Santa Rosa', code: '172016000', type: 'Municipality', latitude: 14.2856, longitude: 121.1667),
      
      // Rizal
      PhilippineLocation(name: 'Rizal', code: '172100000', type: 'Province', latitude: 14.5974, longitude: 121.3162),
      PhilippineLocation(name: 'Antipolo', code: '172101000', type: 'City', latitude: 14.5881, longitude: 121.1714),
      PhilippineLocation(name: 'Cainta', code: '172103000', type: 'Municipality', latitude: 14.5686, longitude: 121.2228),
      PhilippineLocation(name: 'Montalban', code: '172110000', type: 'Municipality', latitude: 14.6674, longitude: 121.3455),
      
      // Bulacan
      PhilippineLocation(name: 'Bulacan', code: '160100000', type: 'Province', latitude: 14.7542, longitude: 120.8479),
      PhilippineLocation(name: 'Malolos', code: '160105000', type: 'City', latitude: 14.8341, longitude: 120.7897),
      PhilippineLocation(name: 'Meycauayan', code: '160108000', type: 'City', latitude: 14.7541, longitude: 120.9751),
      
      // Pampanga
      PhilippineLocation(name: 'Pampanga', code: '151500000', type: 'Province', latitude: 15.0726, longitude: 120.6201),
      PhilippineLocation(name: 'San Fernando', code: '151514000', type: 'City', latitude: 15.0300, longitude: 120.6845),
      PhilippineLocation(name: 'Angeles', code: '151501000', type: 'City', latitude: 15.8742, longitude: 120.5937),
      
      // Quezon
      PhilippineLocation(name: 'Quezon', code: '172200000', type: 'Province', latitude: 14.0762, longitude: 121.6556),
      PhilippineLocation(name: 'Lucena', code: '172206000', type: 'City', latitude: 13.9382, longitude: 121.6197),
      
      // Mindoro
      PhilippineLocation(name: 'Oriental Mindoro', code: '172400000', type: 'Province', latitude: 12.9850, longitude: 121.8303),
      PhilippineLocation(name: 'Calapan', code: '172404000', type: 'City', latitude: 12.8856, longitude: 121.1901),
      
      // Visayas
      PhilippineLocation(name: 'Cebu', code: '070100000', type: 'Province', latitude: 10.3157, longitude: 123.8854),
      PhilippineLocation(name: 'Cebu City', code: '070402000', type: 'City', latitude: 10.3157, longitude: 123.8854),
      PhilippineLocation(name: 'Lapu-Lapu', code: '070409000', type: 'City', latitude: 10.3181, longitude: 124.0181),
      PhilippineLocation(name: 'Mandaue', code: '070410000', type: 'City', latitude: 10.4005, longitude: 123.9758),
      
      PhilippineLocation(name: 'Iloilo', code: '060200000', type: 'Province', latitude: 10.7202, longitude: 122.5621),
      PhilippineLocation(name: 'Iloilo City', code: '060403000', type: 'City', latitude: 10.6915, longitude: 122.5671),
      
      PhilippineLocation(name: 'Bacolod', code: '065911000', type: 'City', latitude: 10.4045, longitude: 122.9469),
      
      // Mindanao
      PhilippineLocation(name: 'Davao', code: '080100000', type: 'Province', latitude: 7.1907, longitude: 125.4553),
      PhilippineLocation(name: 'Davao City', code: '080411000', type: 'City', latitude: 7.1907, longitude: 125.4553),
      
      PhilippineLocation(name: 'Cagayan de Oro', code: '100405000', type: 'City', latitude: 8.4917, longitude: 124.6331),
      PhilippineLocation(name: 'Zamboanga City', code: '095811000', type: 'City', latitude: 6.9271, longitude: 122.0724),
      
      // Luzon Regions
      PhilippineLocation(name: 'Metro Manila', code: '133700000', type: 'Region', latitude: 14.5995, longitude: 120.9842),
      PhilippineLocation(name: 'CALABARZON', code: '171700000', type: 'Region', latitude: 14.0762, longitude: 121.1656),
      PhilippineLocation(name: 'Calauan', code: '172009000', type: 'Municipality', latitude: 14.3534, longitude: 121.2328),
      PhilippineLocation(name: 'Cauayan', code: '172104000', type: 'Municipality', latitude: 14.8166, longitude: 121.3500),
    ];
  }
}