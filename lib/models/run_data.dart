import 'package:latlong2/latlong.dart';

class RunData {
  final String id;
  final DateTime date;
  final double distance; // in kilometers
  final Duration duration;
  final double calories;
  final double avgSpeed;
  final double elevationGain;
  final List<LatLng> route;

  RunData({
    required this.id,
    required this.date,
    required this.distance,
    required this.duration,
    required this.calories,
    required this.avgSpeed,
    required this.elevationGain,
    required this.route,
  });

  // Format duration as string (HH:MM:SS)
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Format date as string
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Format distance with 2 decimal places
  String get formattedDistance {
    return distance.toStringAsFixed(2);
  }

  // Format calories as integer
  String get formattedCalories {
    return calories.toStringAsFixed(0);
  }

  // Format average speed with 1 decimal place
  String get formattedAvgSpeed {
    return avgSpeed.toStringAsFixed(1);
  }

  // Format elevation gain as integer
  String get formattedElevationGain {
    return elevationGain.toStringAsFixed(1);
  }

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'distance': distance,
      'duration': duration.inSeconds,
      'calories': calories,
      'avgSpeed': avgSpeed,
      'elevationGain': elevationGain,
      // Route would need special handling for storage
    };
  }

  // Create from Map for retrieval
  factory RunData.fromMap(Map<String, dynamic> map) {
    return RunData(
      id: map['id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      distance: map['distance'],
      duration: Duration(seconds: map['duration']),
      calories: map['calories'],
      avgSpeed: map['avgSpeed'],
      elevationGain: map['elevationGain'],
      route: [], // Route would need special handling for retrieval
    );
  }
}
