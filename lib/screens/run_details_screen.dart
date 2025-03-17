import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/run.dart';

class RunDetailsScreen extends StatelessWidget {
  final Run run;

  const RunDetailsScreen({super.key, required this.run});

  @override
  Widget build(BuildContext context) {
    // Convert route points to LatLng for flutter_map
    final List<LatLng> routePoints = run.route;

    return Scaffold(
      appBar: AppBar(
        title: Text('Run Details - ${run.startTime.toString().split(' ')[0]}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: routePoints.isNotEmpty
                      ? routePoints.first
                      : const LatLng(0, 0),
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  // Route Polyline
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        color: Colors.blue,
                        strokeWidth: 5,
                      ),
                    ],
                  ),
                  // Start and End Markers
                  MarkerLayer(
                    markers: [
                      if (routePoints.isNotEmpty) ...[
                        // Start marker
                        Marker(
                          point: routePoints.first,
                          width: 80,
                          height: 80,
                          child: const Icon(
                            Icons.play_circle_fill,
                            color: Colors.green,
                            size: 30,
                          ),
                        ),
                        // End marker
                        Marker(
                          point: routePoints.last,
                          width: 80,
                          height: 80,
                          child: const Icon(
                            Icons.stop_circle_outlined,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatCard(
                    'Distance',
                    '${(run.distance / 1000).toStringAsFixed(2)} km',
                    Icons.straighten,
                  ),
                  const SizedBox(height: 16),
                  _buildStatCard(
                    'Duration',
                    '${run.duration.inMinutes} min',
                    Icons.timer,
                  ),
                  const SizedBox(height: 16),
                  _buildStatCard(
                    'Average Pace',
                    '${run.averagePace.toStringAsFixed(1)} min/km',
                    Icons.speed,
                  ),
                  const SizedBox(height: 16),
                  _buildStatCard(
                    'Calories',
                    '${run.calories.toStringAsFixed(0)} kcal',
                    Icons.local_fire_department,
                  ),
                  const SizedBox(height: 16),
                  _buildStatCard(
                    'Coins Earned',
                    '${run.coinsEarned}',
                    Icons.monetization_on,
                  ),
                  if (run.achievements.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Achievements Unlocked',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: run.achievements.entries
                          .where((e) => e.value)
                          .map((e) => Chip(
                                avatar: const Icon(
                                  Icons.emoji_events,
                                  color: Colors.amber,
                                ),
                                label: Text(_getAchievementTitle(e.key)),
                                backgroundColor: Colors.amber.withOpacity(0.2),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getAchievementTitle(String achievementKey) {
    switch (achievementKey) {
      case 'distance_5k':
        return '5K Run';
      case 'distance_10k':
        return '10K Run';
      case 'duration_30min':
        return '30 Minutes';
      case 'duration_1hour':
        return '1 Hour Run';
      case 'pace_5min':
        return '5 min/km';
      case 'pace_6min':
        return '6 min/km';
      default:
        return achievementKey;
    }
  }
}
