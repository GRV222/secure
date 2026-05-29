import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Future<LocationData?> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isEmpty) return null;

      return _fromPlacemark(placemarks.first, position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Location error: $e');
      return null;
    }
  }

  Future<LocationData?> getLocationFromCoords(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return null;
      return _fromPlacemark(placemarks.first, lat, lng);
    } catch (_) {
      return null;
    }
  }

  LocationData _fromPlacemark(Placemark place, double lat, double lng) {
    return LocationData(
      city: place.locality ?? '',
      state: place.administrativeArea ?? '',
      country: place.country ?? '',
      countryCode: place.isoCountryCode ?? '',
      lat: lat,
      lng: lng,
      displayName: _buildDisplayName(place),
    );
  }

  String _buildDisplayName(Placemark place) {
    final parts = <String>[];
    if (place.locality?.isNotEmpty == true) parts.add(place.locality!);
    if (place.administrativeArea?.isNotEmpty == true) parts.add(place.administrativeArea!);
    return parts.join(', ');
  }
}

class LocationData {
  final String city;
  final String state;
  final String country;
  final String countryCode;
  final double lat;
  final double lng;
  final String displayName;

  LocationData({
    required this.city,
    required this.state,
    required this.country,
    required this.countryCode,
    required this.lat,
    required this.lng,
    required this.displayName,
  });

  Map<String, dynamic> toMap() => {
        'city': city,
        'state': state,
        'country': country,
        'countryCode': countryCode,
        'lat': lat,
        'lng': lng,
        'locationDisplay': displayName,
      };

  factory LocationData.fromMap(Map<String, dynamic> data) {
    return LocationData(
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      country: data['country'] ?? '',
      countryCode: data['countryCode'] ?? '',
      lat: (data['lat'] ?? 0.0).toDouble(),
      lng: (data['lng'] ?? 0.0).toDouble(),
      displayName: data['locationDisplay'] ?? '',
    );
  }
}
