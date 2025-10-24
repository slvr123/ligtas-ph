import 'package:http/http.dart' as http;
import 'dart:convert';

class NominatimLocationService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  /// Reverse geocoding: get address from coordinates using Nominatim
  /// This is used for GPS location detection
  Future<Map<String, String>?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final String url = '$_baseUrl/reverse?'
          'format=json&'
          'lat=$latitude&'
          'lon=$longitude&'
          'zoom=10&'
          'addressdetails=1&'
          'language=en';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'LigatsPH-DisasterApp/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          // Build a readable address from components
          String displayName = data['display_name'] ?? '';
          
          // Get the most relevant component
          final city = address['city'] ?? 
                       address['town'] ?? 
                       address['municipality'] ?? 
                       address['village'] ?? 
                       '';
          
          final province = address['state'] ?? '';
          
          String name = city.isNotEmpty ? city : displayName.split(',')[0];

          return {
            'name': name,
            'displayName': displayName,
          };
        }
      }
      return null;
    } catch (e) {
      print('Error reverse geocoding: $e');
      return null;
    }
  }
}