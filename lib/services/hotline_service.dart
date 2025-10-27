class LocalHotline {
  final String agency;
  final String number;

  LocalHotline({
    required this.agency,
    required this.number,
  });
}

class HotlineService {
  static final HotlineService _instance = HotlineService._internal();

  factory HotlineService() {
    return _instance;
  }

  HotlineService._internal();

  // Comprehensive Philippine local hotlines database
  static final Map<String, List<LocalHotline>> _localHotlines = {
    // Metro Manila Area
    'manila': [
      LocalHotline(agency: 'Manila City Disaster Management Office', number: '(02) 8527-0100'),
      LocalHotline(agency: 'Manila City Health Office', number: '(02) 8527-0100 ext. 2156'),
      LocalHotline(agency: 'Manila City Fire Station', number: '(02) 8527-7272'),
    ],
    'quezon city': [
      LocalHotline(agency: 'Quezon City Disaster Risk Reduction Office', number: '(02) 7924-9000'),
      LocalHotline(agency: 'Quezon City Health Department', number: '(02) 7924-2000 local 1255'),
      LocalHotline(agency: 'Quezon City Fire District', number: '(02) 7924-2222'),
    ],
    'makati': [
      LocalHotline(agency: 'Makati City Disaster Management Office', number: '(02) 8844-9600'),
      LocalHotline(agency: 'Makati City Health Department', number: '(02) 8844-3800'),
      LocalHotline(agency: 'Makati City Fire Department', number: '(02) 8819-5555'),
    ],
    'pasay': [
      LocalHotline(agency: 'Pasay City Disaster Management Office', number: '(02) 8833-5577'),
      LocalHotline(agency: 'Pasay City Health Department', number: '(02) 8833-9261'),
      LocalHotline(agency: 'Pasay City Fire Station', number: '(02) 8832-3666'),
    ],
    'taguig': [
      LocalHotline(agency: 'Taguig City Disaster Management Office', number: '(02) 8647-7777'),
      LocalHotline(agency: 'Taguig City Health Department', number: '(02) 8647-7777 local 5500'),
      LocalHotline(agency: 'Taguig City Fire Department', number: '(02) 8647-4000'),
    ],
    'muntinlupa': [
      LocalHotline(agency: 'Muntinlupa City Disaster Management Office', number: '(02) 8861-1234'),
      LocalHotline(agency: 'Muntinlupa City Health Office', number: '(02) 8862-2525'),
      LocalHotline(agency: 'Muntinlupa City Fire Station', number: '(02) 8862-4444'),
    ],
    'cavite': [
      LocalHotline(agency: 'Cavite Provincial Disaster Management Office', number: '(046) 419-2600'),
      LocalHotline(agency: 'Cavite Provincial Health Office', number: '(046) 419-3900'),
      LocalHotline(agency: 'Cavite Fire Department', number: '(046) 419-1234'),
    ],
    'antipolo': [
      LocalHotline(agency: 'Antipolo City Disaster Management Office', number: '(02) 6717-6000'),
      LocalHotline(agency: 'Antipolo City Health Department', number: '(02) 6717-6000 local 2150'),
      LocalHotline(agency: 'Antipolo City Fire Station', number: '(02) 6716-4444'),
    ],
    'cebu': [
      LocalHotline(agency: 'Cebu City Disaster Risk Reduction Office', number: '(032) 255-1191'),
      LocalHotline(agency: 'Cebu City Health Department', number: '(032) 255-1191 local 2100'),
      LocalHotline(agency: 'Cebu City Fire Department', number: '(032) 253-3800'),
    ],
    'davao': [
      LocalHotline(agency: 'Davao City Disaster Risk Reduction Office', number: '(082) 221-6000'),
      LocalHotline(agency: 'Davao City Health Department', number: '(082) 221-6000 local 3500'),
      LocalHotline(agency: 'Davao City Fire Department', number: '(082) 222-5555'),
    ],
  };

  /// Get local hotlines for a specific location
  List<LocalHotline> getLocalHotlines(String location) {
    final normalizedLocation = location.toLowerCase().trim();
    
    // Direct match
    if (_localHotlines.containsKey(normalizedLocation)) {
      return _localHotlines[normalizedLocation]!;
    }

    // Partial match (in case user enters full name with extra text)
    for (var entry in _localHotlines.entries) {
      if (normalizedLocation.contains(entry.key) || entry.key.contains(normalizedLocation)) {
        return entry.value;
      }
    }

    // If no match found, return empty list
    return [];
  }

  /// Get all available locations
  List<String> getAvailableLocations() {
    return _localHotlines.keys.toList()..sort();
  }

  /// Check if location has local hotlines
  bool hasLocalHotlines(String location) {
    return getLocalHotlines(location).isNotEmpty;
  }
}