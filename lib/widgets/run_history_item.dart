import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/run_data.dart';

class RunHistoryItem extends StatelessWidget {
  final RunData run;
  
  const RunHistoryItem({
    super.key,
    required this.run,
  });

  @override
  Widget build(BuildContext context) {
    // Format date with intl package
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).toInt()),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.directions_run,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormat.format(run.date),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeFormat.format(run.date),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${run.formattedDistance} km',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      run.formattedDuration,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem(
                  context,
                  'Avg. Speed',
                  '${run.formattedAvgSpeed} km/h',
                  Icons.speed,
                ),
                _buildMetricItem(
                  context,
                  'Calories',
                  '${run.formattedCalories} kcal',
                  Icons.local_fire_department,
                ),
                _buildMetricItem(
                  context,
                  'Elevation',
                  '${run.formattedElevationGain} m',
                  Icons.terrain,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetricItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

