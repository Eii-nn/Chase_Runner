enum ChaserDifficulty { easy, medium, hard, extreme }

class Chaser {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final ChaserDifficulty difficulty;
  final double baseSpeed; // Base speed in km/h

  Chaser({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.difficulty,
    required this.baseSpeed,
  });

  // Factory method to create default chaser
  factory Chaser.defaultChaser() {
    return Chaser(
      id: 'zombie_1',
      name: 'Zombie Runner',
      description: 'A relentless zombie that never stops chasing you.',
      imagePath: 'assets/images/zombie_runner.png',
      difficulty: ChaserDifficulty.medium,
      baseSpeed: 10.0, // 10 km/h
    );
  }

  // Factory methods for predefined chasers
  factory Chaser.zombie() {
    return Chaser(
      id: 'zombie_1',
      name: 'Zombie Runner',
      description: 'A relentless zombie that never stops chasing you.',
      imagePath: 'assets/images/zombie_runner.png',
      difficulty: ChaserDifficulty.medium,
      baseSpeed: 10.0,
    );
  }

  factory Chaser.ghost() {
    return Chaser(
      id: 'ghost_1',
      name: 'Ghost Runner',
      description: 'A spectral entity that phases through obstacles.',
      imagePath: 'assets/images/ghost_runner.png',
      difficulty: ChaserDifficulty.easy,
      baseSpeed: 9.0,
    );
  }

  factory Chaser.athlete() {
    return Chaser(
      id: 'athlete_1',
      name: 'Pro Athlete',
      description: 'An Olympic-level runner with incredible stamina.',
      imagePath: 'assets/images/athlete_runner.png',
      difficulty: ChaserDifficulty.hard,
      baseSpeed: 12.0,
    );
  }

  factory Chaser.robot() {
    return Chaser(
      id: 'robot_1',
      name: 'T-1000',
      description:
          'A relentless machine that will not stop until it catches you.',
      imagePath: 'assets/images/robot_runner.png',
      difficulty: ChaserDifficulty.extreme,
      baseSpeed: 14.0,
    );
  }

  // Get difficulty as string
  String get difficultyString {
    switch (difficulty) {
      case ChaserDifficulty.easy:
        return 'Easy';
      case ChaserDifficulty.medium:
        return 'Medium';
      case ChaserDifficulty.hard:
        return 'Hard';
      case ChaserDifficulty.extreme:
        return 'Extreme';
    }
  }
}
