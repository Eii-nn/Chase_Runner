import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/run_provider.dart';

class ChaseVisualization extends StatelessWidget {
  const ChaseVisualization({super.key});

  @override
  Widget build(BuildContext context) {
    final runProvider = Provider.of<RunProvider>(context);
    final chaser = runProvider.chaser;
    final chaserDistance = runProvider.chaserDistance;

    // Calculate relative positions
    // The visualization is a horizontal bar showing the runner and chaser
    // The runner is always at the center, and the chaser's position is relative to that

    // Normalize chaser distance to a percentage for visualization
    // Max visible distance is 200m
    const maxVisibleDistance = 200.0;
    final normalizedDistance =
        (chaserDistance / maxVisibleDistance).clamp(0.0, 1.0);

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((0.7 * 255).toInt()),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          // Distance markers
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5,
                (index) => Container(
                  width: 1,
                  height: 10,
                  color: Colors.white.withAlpha((0.3 * 255).toInt()),
                  margin: const EdgeInsets.only(top: 8),
                ),
              ),
            ),
          ),

          // Chaser position
          Positioned(
            left: MediaQuery.of(context).size.width *
                    0.5 *
                    (1 - normalizedDistance) -
                25,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getChaserColor(chaser),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    _getChaserIcon(chaser),
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),

          // Runner position (always at center)
          Positioned(
            left: MediaQuery.of(context).size.width * 0.5 - 25,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.directions_run,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),

          // Distance text
          Positioned(
            bottom: 5,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '${chaserDistance.toInt()} m',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getChaserIcon(dynamic chaser) {
    switch (chaser.id) {
      case 'zombie_1':
        return Icons.sports_kabaddi;
      case 'ghost_1':
        // Changed from Icons.ghost (which doesn't exist) to an alternative icon
        return Icons.blur_on; // A good alternative for a ghost
      case 'athlete_1':
        return Icons.directions_run;
      case 'robot_1':
        return Icons.android;
      default:
        return Icons.person;
    }
  }

  Color _getChaserColor(dynamic chaser) {
    switch (chaser.id) {
      case 'zombie_1':
        return Colors.green;
      case 'ghost_1':
        return Colors.purple;
      case 'athlete_1':
        return Colors.orange;
      case 'robot_1':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
