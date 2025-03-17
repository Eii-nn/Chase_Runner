import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import '../models/run_data.dart';
import '../models/chaser.dart';
import '../models/power_up.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/run.dart';
import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../services/audio_feedback_service.dart';
import '../providers/settings_provider.dart';

// Run modes
enum RunMode { chase, free }

class RunProvider with ChangeNotifier {
  final String userId;
  final SettingsProvider settingsProvider;

  // Run state
  bool _isRunning = false;
  bool _isPaused = false;
  DateTime? _startTime;
  List<Position> _routePoints = [];
  Position? _currentLocation;
  List<RunData> _pastRuns = [];
  RunData? _currentRun;
  RunData? _ghostRun;
  double _distance = 0.0;
  double _elevation = 0.0;
  double _calories = 0.0;
  double _currentSpeed = 0.0;
  double _averageSpeed = 0.0;
  Duration _duration = Duration.zero;
  double _averagePace = 0.0;
  int _coinsEarned = 0;
  Timer? _timer;

  // Run mode
  RunMode _runMode = RunMode.chase;
  RunMode get runMode => _runMode;

  // Streaming controllers
  Stream<Position> positionStream =
      LocationService.getPositionStream().asBroadcastStream();
  final StreamController<Position> _locationController =
      StreamController.broadcast();
  StreamSubscription<Position>? _locationSubscription;

  // For location accuracy
  Position? _lastValidPosition;
  final double _maxSpeedThreshold =
      10.0; // m/s (36 km/h) - unrealistic running speed

  // Audio feedback
  late AudioFeedbackService _audioFeedbackService;

  // Getters
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  DateTime? get startTime => _startTime;
  List<Position> get routePoints => _routePoints;
  Position? get currentLocation => _currentLocation;
  double get distance => _distance;
  double get elevation => _elevation;
  double get calories => _calories;
  double get currentSpeed => _currentSpeed;
  double get averageSpeed => _averageSpeed;
  Duration get duration => _duration;
  double get averagePace => _averagePace;
  int get coinsEarned => _coinsEarned;
  Chaser get chaser => _chaser;
  double get chaserDistance => _chaserDistance;
  List<PowerUp> get availablePowerUps => _availablePowerUps;
  List<PowerUp> get activePowerUps => _activePowerUps;
  List<RunData> get pastRuns => _pastRuns;
  RunData? get currentRun => _currentRun;
  RunData? get ghostRun => _ghostRun;

  // Change the return type to Stream<Position>
  Stream<Position> get locationStream => _locationController.stream;

  // Chase mechanics
  Chaser _chaser = Chaser.defaultChaser();
  double _chaserDistance = 100.0; // meters behind
  List<PowerUp> _availablePowerUps = [];
  final List<PowerUp> _activePowerUps = [];

  // Add completed run storage
  RunData? _completedRun;
  RunData? get completedRun => _completedRun;

  // Initialize
  RunProvider({required this.userId, required this.settingsProvider}) {
    _audioFeedbackService = AudioFeedbackService(settingsProvider);
    _loadPastRuns();
  }

  void _loadPastRuns() {
    // In a real app, load from local storage or cloud
    // For now, we'll use dummy data
    _pastRuns = [
      RunData(
        id: '1',
        date: DateTime.now().subtract(const Duration(days: 2)),
        distance: 5.2,
        duration: const Duration(minutes: 28, seconds: 45),
        calories: 320,
        avgSpeed: 11.2,
        elevationGain: 45,
        route: [],
      ),
      RunData(
        id: '2',
        date: DateTime.now().subtract(const Duration(days: 5)),
        distance: 3.8,
        duration: const Duration(minutes: 22, seconds: 15),
        calories: 240,
        avgSpeed: 10.5,
        elevationGain: 30,
        route: [],
      ),
    ];
  }

  // Run control methods
  void startRun(
      {Chaser? customChaser,
      RunData? ghostRunData,
      RunMode mode = RunMode.chase}) {
    _isRunning = true;
    _isPaused = false;
    _startTime = DateTime.now();
    _routePoints = [];
    _distance = 0;
    _duration = Duration.zero;
    _runMode = mode;

    // Set up chaser if provided and in chase mode
    if (mode == RunMode.chase && customChaser != null) {
      _chaser = customChaser;
    }

    // Set up ghost run if provided
    _ghostRun = ghostRunData;

    // Start location tracking
    _startLocationTracking();

    // Start duration timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _duration = Duration(seconds: _duration.inSeconds + 1);

      // Announce time milestones
      _audioFeedbackService.announceTimeMilestone(_duration);

      notifyListeners();
    });

    // Announce run start
    _audioFeedbackService.announceRunState(AudioCueType.startRun);

    notifyListeners();
  }

  void pauseRun() {
    _isRunning = false;
    _isPaused = true;
    _timer?.cancel();
    _locationSubscription?.pause();

    // Announce run pause
    _audioFeedbackService.announceRunState(AudioCueType.pauseRun);

    notifyListeners();
  }

  void resumeRun() {
    _isRunning = true;
    _isPaused = false;
    _startLocationTracking();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _duration = Duration(seconds: _duration.inSeconds + 1);

      // Announce time milestones
      _audioFeedbackService.announceTimeMilestone(_duration);

      notifyListeners();
    });
    _locationSubscription?.resume();

    // Announce run resume
    _audioFeedbackService.announceRunState(AudioCueType.resumeRun);

    notifyListeners();
  }

  Future<void> endRun() async {
    _isRunning = false;
    _isPaused = false;
    _timer?.cancel();
    await _locationSubscription?.cancel();

    // Calculate achievements
    Map<String, dynamic> achievements = _calculateAchievements();

    // Convert Position objects to LatLng for the Run model
    final List<latlong2.LatLng> routeLatLng = _routePoints
        .map((pos) => latlong2.LatLng(pos.latitude, pos.longitude))
        .toList();

    // Create run document
    final run = Run(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      startTime: _startTime!,
      endTime: DateTime.now(),
      distance: _distance,
      duration: _duration,
      route: routeLatLng,
      averagePace: _duration.inMinutes / (_distance / 1000), // min/km
      calories: _calories,
      coinsEarned: (_distance / 100).floor(), // 1 coin per 100 meters
      achievements: achievements,
    );

    // Store the completed run data before resetting
    _completedRun = RunData(
      id: run.id,
      date: run.startTime,
      distance: run.distance / 1000, // Convert to kilometers
      duration: run.duration,
      calories: run.calories,
      avgSpeed: run.distance / run.duration.inSeconds, // meters per second
      elevationGain: _elevation,
      route: routeLatLng,
    );

    // Announce run end
    _audioFeedbackService.announceRunState(AudioCueType.endRun);

    // Save to Firestore
    try {
      await FirebaseFirestore.instance
          .collection('runs')
          .doc(run.id)
          .set(run.toFirestore());

      // Add to past runs
      _pastRuns = [_completedRun!, ..._pastRuns];
    } catch (e) {
      debugPrint('Error saving run: $e');
    }

    // Reset state
    _startTime = null;
    _routePoints = [];
    _currentLocation = null;
    _distance = 0;
    _duration = Duration.zero;
    notifyListeners();
  }

  void _startLocationTracking() {
    _locationSubscription = positionStream.listen((Position position) {
      // Filter out inaccurate locations
      if (position.accuracy > 30) {
        // More than 30 meters accuracy is poor
        debugPrint('Skipping inaccurate location: ${position.accuracy}m');
        return; // Skip this update
      }

      // Check for unrealistic movement if we have a previous position
      if (_lastValidPosition != null && _routePoints.isNotEmpty) {
        final lastPosition = _lastValidPosition!;
        final distanceInMeters = Geolocator.distanceBetween(
          lastPosition.latitude,
          lastPosition.longitude,
          position.latitude,
          position.longitude,
        );

        final timeInSeconds = position.timestamp
                .difference(lastPosition.timestamp)
                .inMilliseconds /
            1000;
        if (timeInSeconds > 0) {
          final speed = distanceInMeters / timeInSeconds; // m/s

          // If speed is unrealistically high, skip this update
          if (speed > _maxSpeedThreshold) {
            debugPrint(
                'Skipping unrealistic movement: ${speed.toStringAsFixed(1)} m/s');
            return;
          }
        }
      }

      // Update current location and store as last valid position
      _currentLocation = position;
      _lastValidPosition = position;
      _locationController.add(position);

      if (_routePoints.isNotEmpty) {
        // Calculate distance from last point
        final lastPosition = _routePoints.last;
        final distanceInMeters = Geolocator.distanceBetween(
          lastPosition.latitude,
          lastPosition.longitude,
          position.latitude,
          position.longitude,
        );

        // Only add to distance if it's a reasonable value (avoid GPS jumps)
        if (distanceInMeters < 30) {
          // Reduced from 50m to 30m for better accuracy
          _distance += distanceInMeters;

          // Update metrics with new position
          _updateMetricsWithNewPosition(position, lastPosition);

          // Announce distance milestones
          _audioFeedbackService.announceDistanceMilestone(_distance / 1000);

          // Provide pace feedback
          if (_currentSpeed > 0 && _averagePace > 0) {
            final currentPace = 60 / (_currentSpeed / 1000); // min/km
            _audioFeedbackService.announcePaceFeedback(
                currentPace, _averagePace);
          }

          // Only update chaser in chase mode
          if (_runMode == RunMode.chase) {
            _updateChaserPosition();
            _checkForPowerUps();
            _processActivePowerUps();
          }
        }
      }

      // Add current position to route
      _routePoints.add(position);
      notifyListeners();
    });
  }

  // Location tracking
  void _updateMetricsWithNewPosition(Position position, Position lastPosition) {
    if (_routePoints.isNotEmpty) {
      // Calculate distance from last point
      final newDistance = Geolocator.distanceBetween(
        lastPosition.latitude,
        lastPosition.longitude,
        position.latitude,
        position.longitude,
      );
      _distance += newDistance / 1000; // Convert to kilometers
    }

    _routePoints.add(position);

    // Update elevation
    if (position.altitude > 0) {
      if (position.altitude > _currentLocation!.altitude) {
        _elevation += position.altitude - _currentLocation!.altitude;
      }
    }

    // Update current speed (km/h)
    if (position.speed > 0) {
      _currentSpeed = position.speed * 3.6; // Convert m/s to km/h
    }

    // Update average speed
    _averageSpeed = _distance / (_duration.inSeconds / 3600);

    // Update average pace (minutes per kilometer)
    if (_distance > 0) {
      _averagePace = _duration.inMinutes / _distance;
    }

    // Update calories (simple estimation)
    // Assuming 60 calories burned per km for a 70kg person
    _calories = _distance * 60;

    // Update coins earned (1 coin per 100 meters)
    _coinsEarned = (_distance * 1000 / 100).floor();
  }

  // Chase mechanics
  void _updateChaserPosition() {
    if (_routePoints.isEmpty) return;

    // Calculate chaser speed based on difficulty and user's average speed
    double chaserSpeedFactor = 1.0;

    switch (_chaser.difficulty) {
      case ChaserDifficulty.easy:
        chaserSpeedFactor = 0.9; // 90% of user's speed
        break;
      case ChaserDifficulty.medium:
        chaserSpeedFactor = 1.0; // Same as user's speed
        break;
      case ChaserDifficulty.hard:
        chaserSpeedFactor = 1.1; // 110% of user's speed
        break;
      case ChaserDifficulty.extreme:
        chaserSpeedFactor = 1.2; // 120% of user's speed
        break;
    }

    // Apply power-up effects to chaser speed
    for (var powerUp in _activePowerUps) {
      if (powerUp.type == PowerUpType.slowChaser) {
        chaserSpeedFactor *= 0.7; // Slow chaser by 30%
      }
    }

    // Calculate how much the chaser should move
    double chaserSpeed = _averageSpeed * chaserSpeedFactor;

    // Convert to meters per second
    double chaserMeterPerSecond = chaserSpeed / 3.6;

    // Assume this is called roughly every second (or adjust accordingly)
    _chaserDistance -= chaserMeterPerSecond;

    // Ensure chaser distance doesn't go below 0
    _chaserDistance = max(0, _chaserDistance);

    // Provide audio feedback based on chaser distance
    _provideChaserFeedback();
  }

  void _provideChaserFeedback() {
    // Use the audio feedback service to announce chaser warnings
    _audioFeedbackService.announceChaserWarning(_chaser.name, _chaserDistance);
  }

  // Power-up mechanics
  void _checkForPowerUps() {
    if (_availablePowerUps.isEmpty) return;

    // Check if any power-ups should be collected based on distance
    for (var powerUp in _availablePowerUps) {
      if (!powerUp.isCollected && _distance >= powerUp.appearDistance) {
        // In a real app, we'd check proximity to the actual power-up location
        // For this demo, we'll just collect it when we reach the right distance

        powerUp.isCollected = true;
        _activatePowerUp(powerUp);

        // Remove from available power-ups
        _availablePowerUps.removeWhere((p) => p.id == powerUp.id);

        break; // Only collect one power-up at a time
      }
    }
  }

  void _activatePowerUp(PowerUp powerUp) {
    // Clone the power-up and set activation time
    final activePowerUp = PowerUp(
      id: powerUp.id,
      type: powerUp.type,
      duration: powerUp.duration,
      appearDistance: powerUp.appearDistance,
      isCollected: true,
      activatedAt: DateTime.now(),
    );

    _activePowerUps.add(activePowerUp);

    // Provide feedback based on power-up type
    String powerUpName = "";
    switch (powerUp.type) {
      case PowerUpType.speedBoost:
        powerUpName = "Speed boost";
        break;
      case PowerUpType.slowChaser:
        powerUpName = "${_chaser.name} slow down";
        break;
      case PowerUpType.shield:
        powerUpName = "Shield";
        break;
      case PowerUpType.teleport:
        // Increase distance from chaser
        _chaserDistance += 50;
        powerUpName = "Teleport";
        break;
    }

    // Announce power-up activation
    _audioFeedbackService.announcePowerUp(
        AudioCueType.powerUpActivated, powerUpName);

    notifyListeners();
  }

  void _processActivePowerUps() {
    final now = DateTime.now();
    final expiredPowerUps = <PowerUp>[];

    for (var powerUp in _activePowerUps) {
      if (powerUp.activatedAt != null) {
        final elapsedDuration = now.difference(powerUp.activatedAt!);

        if (elapsedDuration >= powerUp.duration) {
          expiredPowerUps.add(powerUp);

          // Provide feedback that power-up expired
          String powerUpName = "";
          switch (powerUp.type) {
            case PowerUpType.speedBoost:
              powerUpName = "Speed boost";
              break;
            case PowerUpType.slowChaser:
              powerUpName = "${_chaser.name} slow down";
              break;
            case PowerUpType.shield:
              powerUpName = "Shield";
              break;
            case PowerUpType.teleport:
              // No expiration effect for teleport
              continue;
          }

          // Announce power-up expiration
          _audioFeedbackService.announcePowerUp(
              AudioCueType.powerUpExpired, powerUpName);
        }
      }
    }

    // Remove expired power-ups
    _activePowerUps.removeWhere((p) => expiredPowerUps.contains(p));
  }

  // Cleanup
  @override
  void dispose() {
    _timer?.cancel();
    _locationSubscription?.cancel();
    _audioFeedbackService.dispose();
    super.dispose();
  }

  Map<String, dynamic> _calculateAchievements() {
    Map<String, dynamic> achievements = {};

    // Distance achievements
    if (_distance >= 5000) {
      achievements['distance_5k'] = true;
      _audioFeedbackService.announceAchievement("5K Run");
    }
    if (_distance >= 10000) {
      achievements['distance_10k'] = true;
      _audioFeedbackService.announceAchievement("10K Run");
    }

    // Duration achievements
    if (_duration.inMinutes >= 30) {
      achievements['duration_30min'] = true;
      _audioFeedbackService.announceAchievement("30 Minute Run");
    }
    if (_duration.inMinutes >= 60) {
      achievements['duration_1hour'] = true;
      _audioFeedbackService.announceAchievement("1 Hour Run");
    }

    // Pace achievements
    double pace = _duration.inMinutes / (_distance / 1000); // min/km
    if (pace <= 5) {
      achievements['pace_5min'] = true; // 5 min/km or faster
      _audioFeedbackService.announceAchievement("Speed Demon");
    }
    if (pace <= 6) {
      achievements['pace_6min'] = true;
      _audioFeedbackService.announceAchievement("Fast Runner");
    }

    return achievements;
  }
}
