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
    'marikina': [
      LocalHotline(agency: 'Marikina City Disaster Risk Reduction Office', number: '(02) 6646-6000'),
      LocalHotline(agency: 'Marikina City Health Department', number: '(02) 6646-6000 local 2500'),
      LocalHotline(agency: 'Marikina City Fire Department', number: '(02) 6645-5555'),
    ],
    'san juan': [
      LocalHotline(agency: 'San Juan City Disaster Management Office', number: '(02) 7231-3000'),
      LocalHotline(agency: 'San Juan City Health Office', number: '(02) 7231-3000 local 1800'),
      LocalHotline(agency: 'San Juan City Fire Station', number: '(02) 7231-4444'),
    ],
    'las pinas': [
      LocalHotline(agency: 'Las Piñas City Disaster Management Office', number: '(02) 8161-9100'),
      LocalHotline(agency: 'Las Piñas City Health Department', number: '(02) 8161-9100 local 3200'),
      LocalHotline(agency: 'Las Piñas City Fire Department', number: '(02) 8161-7777'),
    ],
    'paranaque': [
      LocalHotline(agency: 'Parañaque City Disaster Management Office', number: '(02) 8826-6000'),
      LocalHotline(agency: 'Parañaque City Health Department', number: '(02) 8826-6000 local 2800'),
      LocalHotline(agency: 'Parañaque City Fire Department', number: '(02) 8826-3333'),
    ],
    'cavite': [
      LocalHotline(agency: 'Cavite Provincial Disaster Management Office', number: '(046) 419-2600'),
      LocalHotline(agency: 'Cavite Provincial Health Office', number: '(046) 419-3900'),
      LocalHotline(agency: 'Cavite Fire Department', number: '(046) 419-1234'),
    ],
    'rizal': [
      LocalHotline(agency: 'Rizal Provincial Disaster Management Office', number: '(02) 6954-4000'),
      LocalHotline(agency: 'Rizal Provincial Health Office', number: '(02) 6954-4000 local 2300'),
      LocalHotline(agency: 'Rizal Provincial Fire Office', number: '(02) 6956-7777'),
    ],
    'bulacan': [
      LocalHotline(agency: 'Bulacan Provincial Disaster Management Office', number: '(044) 791-2600'),
      LocalHotline(agency: 'Bulacan Provincial Health Office', number: '(044) 791-2600 local 5000'),
      LocalHotline(agency: 'Bulacan Fire Department', number: '(044) 791-1234'),
    ],
    'antipolo': [
      LocalHotline(agency: 'Antipolo City Disaster Management Office', number: '(02) 6717-6000'),
      LocalHotline(agency: 'Antipolo City Health Department', number: '(02) 6717-6000 local 2150'),
      LocalHotline(agency: 'Antipolo City Fire Station', number: '(02) 6716-4444'),
    ],
    // Visayas
    'cebu': [
      LocalHotline(agency: 'Cebu City Disaster Risk Reduction Office', number: '(032) 255-1191'),
      LocalHotline(agency: 'Cebu City Health Department', number: '(032) 255-1191 local 2100'),
      LocalHotline(agency: 'Cebu City Fire Department', number: '(032) 253-3800'),
    ],
    'mandaue': [
      LocalHotline(agency: 'Mandaue City Disaster Management Office', number: '(032) 345-1000'),
      LocalHotline(agency: 'Mandaue City Health Department', number: '(032) 345-1000 local 2100'),
      LocalHotline(agency: 'Mandaue City Fire Department', number: '(032) 346-5555'),
    ],
    'lapu-lapu': [
      LocalHotline(agency: 'Lapu-Lapu City Disaster Management Office', number: '(032) 495-3300'),
      LocalHotline(agency: 'Lapu-Lapu City Health Department', number: '(032) 495-3300 local 1800'),
      LocalHotline(agency: 'Lapu-Lapu City Fire Department', number: '(032) 495-4444'),
    ],
    'iloilo': [
      LocalHotline(agency: 'Iloilo City Disaster Risk Reduction Office', number: '(033) 336-0001'),
      LocalHotline(agency: 'Iloilo City Health Department', number: '(033) 336-0001 local 2000'),
      LocalHotline(agency: 'Iloilo City Fire Department', number: '(033) 335-5555'),
    ],
    'bacolod': [
      LocalHotline(agency: 'Bacolod City Disaster Management Office', number: '(034) 702-9000'),
      LocalHotline(agency: 'Bacolod City Health Department', number: '(034) 702-9000 local 3100'),
      LocalHotline(agency: 'Bacolod City Fire Department', number: '(034) 702-4444'),
    ],
    // Mindanao
    'davao': [
      LocalHotline(agency: 'Davao City Disaster Risk Reduction Office', number: '(082) 221-6000'),
      LocalHotline(agency: 'Davao City Health Department', number: '(082) 221-6000 local 3500'),
      LocalHotline(agency: 'Davao City Fire Department', number: '(082) 222-5555'),
    ],
    'tagum': [
      LocalHotline(agency: 'Tagum City Disaster Management Office', number: '(084) 216-6000'),
      LocalHotline(agency: 'Tagum City Health Department', number: '(084) 216-6000 local 2200'),
      LocalHotline(agency: 'Tagum City Fire Department', number: '(084) 216-3333'),
    ],
    'cagayan de oro': [
      LocalHotline(agency: 'Cagayan de Oro Disaster Management Office', number: '(088) 858-6000'),
      LocalHotline(agency: 'Cagayan de Oro Health Department', number: '(088) 858-6000 local 2500'),
      LocalHotline(agency: 'Cagayan de Oro Fire Department', number: '(088) 857-7777'),
    ],
    'general santos': [
      LocalHotline(agency: 'General Santos City Disaster Management Office', number: '(083) 552-3500'),
      LocalHotline(agency: 'General Santos City Health Department', number: '(083) 552-3500 local 1900'),
      LocalHotline(agency: 'General Santos City Fire Department', number: '(083) 552-1234'),
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