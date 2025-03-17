import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../providers/run_provider.dart';

class RunSummaryScreen extends StatelessWidget {
  const RunSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final runProvider = Provider.of<RunProvider>(context);
    final completedRun = runProvider.completedRun;

    if (completedRun == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Run Summary'),
        ),
        body: const Center(
          child: Text('No run data available'),
        ),
      );
    }

    // Calculate pace in min/km
    double paceMinutes = 0;
    double paceSeconds = 0;
    String paceText = '--:--';

    if (completedRun.distance > 0) {
      final pace =
          completedRun.duration.inSeconds / (completedRun.distance * 60);
      if (pace.isFinite) {
        paceMinutes = pace.floor().toDouble();
        paceSeconds = ((pace - paceMinutes) * 60).round().toDouble();
        paceText =
            '${paceMinutes.toInt()}:${paceSeconds.toInt().toString().padLeft(2, '0')}';
      }
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Map
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildMap(context, completedRun),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.black),
              ),
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/home'),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.save, color: Colors.black),
                ),
                onPressed: () => _showSaveDialog(context),
              ),
            ],
          ),

          // Run Title and Date
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          runProvider.runMode == RunMode.chase
                              ? 'Chase Run'
                              : 'Free Run',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('MMM d, yyyy • h:mm a')
                            .format(completedRun.date),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Great Job!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You completed your run successfully',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Primary Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildPrimaryStat(
                          context,
                          completedRun.distance.isFinite
                              ? '${completedRun.distance.toStringAsFixed(2)}'
                              : '--',
                          'km',
                          'Distance',
                          Icons.straighten,
                          Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 50,
                        width: 1,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildPrimaryStat(
                          context,
                          _formatDuration(completedRun.duration),
                          '',
                          'Duration',
                          Icons.timer,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 50,
                        width: 1,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildPrimaryStat(
                          context,
                          paceText,
                          'min/km',
                          'Pace',
                          Icons.speed,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Secondary Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCard(
                          context,
                          Icons.local_fire_department,
                          Colors.deepOrange,
                          completedRun.calories.isFinite
                              ? '${completedRun.calories.toStringAsFixed(0)} kcal'
                              : '-- kcal',
                          'Calories',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDetailCard(
                          context,
                          Icons.terrain,
                          Colors.brown,
                          completedRun.elevationGain.isFinite
                              ? '${completedRun.elevationGain.toStringAsFixed(0)} m'
                              : '-- m',
                          'Elevation',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCard(
                          context,
                          Icons.speed,
                          Colors.blue,
                          completedRun.avgSpeed.isFinite
                              ? '${completedRun.avgSpeed.toStringAsFixed(1)} km/h'
                              : '-- km/h',
                          'Avg Speed',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDetailCard(
                          context,
                          Icons.monetization_on,
                          Colors.amber,
                          '${(completedRun.distance * 10).isFinite ? (completedRun.distance * 10).toInt() : 0}',
                          'Coins Earned',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Achievements
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Achievements',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildAchievements(context, completedRun),
                ],
              ),
            ),
          ),

          // Action Buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pushReplacementNamed('/home'),
                      icon: const Icon(Icons.home),
                      label: const Text('HOME'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pushReplacementNamed('/setup'),
                      icon: const Icon(Icons.directions_run),
                      label: const Text('NEW RUN'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(BuildContext context, dynamic completedRun) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: completedRun.route.isNotEmpty
            ? completedRun.route.first
            : const LatLng(51.5074, -0.1278),
        initialZoom: 14,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        if (completedRun.route.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: completedRun.route,
                color: Theme.of(context).primaryColor,
                strokeWidth: 4,
              ),
            ],
          ),
        if (completedRun.route.isNotEmpty)
          MarkerLayer(
            markers: [
              // Start marker
              Marker(
                point: completedRun.route.first,
                width: 20,
                height: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
              // End marker
              Marker(
                point: completedRun.route.last,
                width: 20,
                height: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.flag,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPrimaryStat(
    BuildContext context,
    String value,
    String unit,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit.isNotEmpty)
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    IconData icon,
    Color color,
    String value,
    String label,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements(BuildContext context, dynamic completedRun) {
    // Define some achievement criteria
    final achievements = [
      {
        'title': 'Distance Goal',
        'description': 'Run more than 3 km',
        'achieved': completedRun.distance >= 3,
        'icon': Icons.straighten,
      },
      {
        'title': 'Speed Demon',
        'description': 'Average speed above 10 km/h',
        'achieved':
            completedRun.avgSpeed.isFinite && completedRun.avgSpeed >= 10,
        'icon': Icons.speed,
      },
      {
        'title': 'Calorie Burner',
        'description': 'Burn more than 200 calories',
        'achieved':
            completedRun.calories.isFinite && completedRun.calories >= 200,
        'icon': Icons.local_fire_department,
      },
      {
        'title': 'Endurance Master',
        'description': 'Run for more than 30 minutes',
        'achieved': completedRun.duration.inMinutes >= 30,
        'icon': Icons.timer,
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: achievements.map((achievement) {
            final achieved = achievement['achieved'] as bool;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: achieved
                          ? Colors.amber.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      achievement['icon'] as IconData,
                      color: achieved ? Colors.amber : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement['title'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: achieved ? Colors.black : Colors.grey,
                          ),
                        ),
                        Text(
                          achievement['description'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    achieved
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: achieved ? Colors.green : Colors.grey,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  void _showSaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Run Saved'),
        content: const Text('Your run has been saved successfully!'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
