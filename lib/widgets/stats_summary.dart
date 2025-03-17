import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/run_provider.dart';

class StatsSummary extends StatelessWidget {
  const StatsSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final runProvider = Provider.of<RunProvider>(context);
    final pastRuns = runProvider.pastRuns;

    // Calculate total stats
    double totalDistance = 0;
    Duration totalDuration = Duration.zero;
    int totalRuns = pastRuns.length;
    double totalCalories = 0;

    for (var run in pastRuns) {
      totalDistance += run.distance;
      totalDuration += run.duration;
      totalCalories += run.calories;
    }

    // Calculate average pace (min/km)
    double avgPace =
        totalDistance > 0 ? totalDuration.inMinutes / totalDistance : 0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Stats',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'All Time',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total Runs',
                    totalRuns.toString(),
                    Icons.directions_run,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Distance',
                    '${totalDistance.toStringAsFixed(1)} km',
                    Icons.straighten,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Time',
                    _formatDuration(totalDuration),
                    Icons.timer,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Calories',
                    '${totalCalories.toStringAsFixed(0)}',
                    Icons.local_fire_department,
                  ),
                ),
              ],
            ),
            if (avgPace > 0) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Avg. Pace',
                      '${avgPace.toStringAsFixed(1)} min/km',
                      Icons.speed,
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
