import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Mendapatkan koordinat Latitude dan Longitude perangkat saat ini.
  Future<Map<String, double>> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
    };
  }

  /// Memeriksa apakah lokasi saat ini berada dalam radius geofence.
  /// Mengembalikan true jika dalam radius, false jika tidak.
  Future<bool> checkGeofence(double targetLat, double targetLon, double radius) async {
    final currentLocation = await getCurrentLocation();
    double distance = Geolocator.distanceBetween(
      currentLocation['latitude']!,
      currentLocation['longitude']!,
      targetLat,
      targetLon,
    );
    return distance <= radius;
  }
}