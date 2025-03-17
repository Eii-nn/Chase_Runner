import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/run_provider.dart';
import '../models/power_up.dart';

class PowerUpIndicator extends StatelessWidget {
  const PowerUpIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final runProvider = Provider.of<RunProvider>(context);
    final activePowerUps = runProvider.activePowerUps;

    if (activePowerUps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: activePowerUps.map((powerUp) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getPowerUpIcon(powerUp),
                color: _getPowerUpColor(powerUp),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                powerUp.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${powerUp.remainingSeconds}s',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getPowerUpIcon(PowerUp powerUp) {
    switch (powerUp.type) {
      case PowerUpType.speedBoost:
        return Icons.flash_on;
      case PowerUpType.slowChaser:
        return Icons.snooze;
      case PowerUpType.shield:
        return Icons.shield;
      case PowerUpType.teleport:
        return Icons.swap_horiz;
    }
  }

  Color _getPowerUpColor(PowerUp powerUp) {
    switch (powerUp.type) {
      case PowerUpType.speedBoost:
        return Colors.yellow;
      case PowerUpType.slowChaser:
        return Colors.blue;
      case PowerUpType.shield:
        return Colors.green;
      case PowerUpType.teleport:
        return Colors.purple;
    }
  }
}
