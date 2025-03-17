import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class Run {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final double distance; // in meters
  final Duration duration;
  final List<LatLng> route;
  final double averagePace; // minutes per kilometer
  final double calories;
  final int coinsEarned;
  final Map<String, dynamic> achievements;

  Run({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.distance,
    required this.duration,
    required this.route,
    required this.averagePace,
    required this.calories,
    required this.coinsEarned,
    required this.achievements,
  });

  factory Run.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Run(
      id: doc.id,
      userId: data['userId'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      distance: (data['distance'] ?? 0.0).toDouble(),
      duration: Duration(seconds: data['durationSeconds'] ?? 0),
      route: (data['route'] as List<dynamic>?)
              ?.map((point) => LatLng((point['latitude'] as num).toDouble(),
                  (point['longitude'] as num).toDouble()))
              .toList() ??
          [],
      averagePace: (data['averagePace'] ?? 0.0).toDouble(),
      calories: (data['calories'] ?? 0.0).toDouble(),
      coinsEarned: data['coinsEarned'] ?? 0,
      achievements: data['achievements'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'distance': distance,
      'durationSeconds': duration.inSeconds,
      'route': route
          .map((point) => {
                'latitude': point.latitude,
                'longitude': point.longitude,
              })
          .toList(),
      'averagePace': averagePace,
      'calories': calories,
      'coinsEarned': coinsEarned,
      'achievements': achievements,
    };
  }
}
