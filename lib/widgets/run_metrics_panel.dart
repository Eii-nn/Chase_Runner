import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/run_provider.dart';

class RunMetricsPanel extends StatelessWidget {
  const RunMetricsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final runProvider = Provider.of<RunProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Primary metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric(
                context,
                'Distance',
                '${runProvider.distance.toStringAsFixed(2)} km',
                Icons.straighten,
              ),
              _buildMetric(
                context,
                'Duration',
                _formatDuration(runProvider.duration),
                Icons.timer,
              ),
              _buildMetric(
                context,
                'Pace',
                '${runProvider.currentSpeed.toStringAsFixed(1)} km/h',
                Icons.speed,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Secondary metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric(
                context,
                'Calories',
                '${runProvider.calories.toInt()} kcal',
                Icons.local_fire_department,
              ),
              _buildMetric(
                context,
                'Elevation',
                '${runProvider.elevation.toInt()} m',
                Icons.terrain,
              ),
              _buildMetric(
                context,
                'Chaser',
                '${runProvider.chaserDistance.toInt()} m',
                Icons.person_pin_circle,
                color: _getChaserDistanceColor(runProvider.chaserDistance),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color ?? Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  Color _getChaserDistanceColor(double distance) {
    if (distance <= 20) {
      return Colors.red;
    } else if (distance <= 50) {
      return Colors.orange;
    } else if (distance <= 100) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }
}
