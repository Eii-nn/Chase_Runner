enum PowerUpType { speedBoost, slowChaser, shield, teleport }

class PowerUp {
  final String id;
  final PowerUpType type;
  final Duration duration;
  final double appearDistance; // At what distance this power-up appears
  bool isCollected;
  DateTime? activatedAt;

  PowerUp({
    required this.id,
    required this.type,
    required this.duration,
    required this.appearDistance,
    this.isCollected = false,
    this.activatedAt,
  });

  // Get name based on type
  String get name {
    switch (type) {
      case PowerUpType.speedBoost:
        return 'Speed Boost';
      case PowerUpType.slowChaser:
        return 'Slow Chaser';
      case PowerUpType.shield:
        return 'Shield';
      case PowerUpType.teleport:
        return 'Teleport';
    }
  }

  // Get description based on type
  String get description {
    switch (type) {
      case PowerUpType.speedBoost:
        return 'Temporarily increases your running speed.';
      case PowerUpType.slowChaser:
        return 'Temporarily slows down your chaser.';
      case PowerUpType.shield:
        return 'Temporarily prevents the chaser from catching you.';
      case PowerUpType.teleport:
        return 'Instantly teleports you ahead, increasing the distance from your chaser.';
    }
  }

  // Get icon based on type
  String get iconPath {
    switch (type) {
      case PowerUpType.speedBoost:
        return 'assets/images/speed_boost.png';
      case PowerUpType.slowChaser:
        return 'assets/images/slow_chaser.png';
      case PowerUpType.shield:
        return 'assets/images/shield.png';
      case PowerUpType.teleport:
        return 'assets/images/teleport.png';
    }
  }

  // Check if power-up is active
  bool get isActive {
    if (activatedAt == null) return false;

    final now = DateTime.now();
    final elapsedDuration = now.difference(activatedAt!);

    return elapsedDuration < duration;
  }

  // Get remaining duration in seconds
  int get remainingSeconds {
    if (activatedAt == null) return 0;
    if (!isActive) return 0;

    final now = DateTime.now();
    final elapsedDuration = now.difference(activatedAt!);
    final remainingDuration = duration - elapsedDuration;

    return remainingDuration.inSeconds;
  }
}
