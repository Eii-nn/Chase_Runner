import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  static Future<bool> checkPermissions() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requestedPermission = await Geolocator.requestPermission();
        if (requestedPermission == LocationPermission.denied ||
            requestedPermission == LocationPermission.deniedForever) {
          return null;
        }
      }

      // Use high accuracy and a small distance filter
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 2, // Update every 2 meters
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  static double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  static double calculateTotalDistance(List<LatLng> points) {
    double totalDistance = 0;

    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += calculateDistance(points[i], points[i + 1]);
    }

    return totalDistance;
  }

  static LatLng positionToLatLng(Position position) {
    return LatLng(position.latitude, position.longitude);
  }
}
