import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../providers/settings_provider.dart';

enum AudioCueType {
  distanceMilestone,
  paceFeedback,
  timeMilestone,
  startRun,
  pauseRun,
  resumeRun,
  endRun,
  chaserWarning,
  powerUpActivated,
  powerUpExpired,
  achievement
}

class AudioFeedbackService {
  final FlutterTts _flutterTts = FlutterTts();
  final SettingsProvider _settingsProvider;

  // Track last announcements to avoid repetition
  DateTime? _lastDistanceAnnouncement;
  DateTime? _lastPaceAnnouncement;
  DateTime? _lastTimeAnnouncement;
  double? _lastAnnouncedDistance;
  int? _lastAnnouncedMinute;

  // Minimum time between similar announcements (in seconds)
  final int _minAnnouncementInterval = 60;

  AudioFeedbackService(this._settingsProvider) {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);

    // Apply settings
    await _flutterTts.setVolume(_settingsProvider.audioVolume);

    // Set voice based on settings
    if (_settingsProvider.voiceType == 'coach') {
      await _flutterTts
          .setVoice({"name": "en-us-x-sfg#male_2", "locale": "en-US"});
    } else if (_settingsProvider.voiceType == 'zombie') {
      await _flutterTts.setPitch(0.8); // Lower pitch for zombie voice
      await _flutterTts.setSpeechRate(0.4); // Slower for zombie voice
    } else {
      await _flutterTts.setPitch(1.0);
    }
  }

  Future<void> speak(String text) async {
    if (!_settingsProvider.audioEnabled) return;

    try {
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS Error: $e');
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  // Distance milestone announcements (every km or mile)
  Future<void> announceDistanceMilestone(double distanceKm) async {
    if (!_settingsProvider.audioEnabled) return;

    final now = DateTime.now();
    final distanceUnit = _settingsProvider.distanceUnit;

    // Convert to miles if needed
    final distance =
        distanceUnit == 'miles' ? distanceKm * 0.621371 : distanceKm;
    final unit = distanceUnit == 'miles' ? 'miles' : 'kilometers';

    // Round to nearest 0.5
    final roundedDistance = (distance * 2).round() / 2;

    // Check if we've already announced this distance or if it's too soon
    if (_lastAnnouncedDistance == roundedDistance) return;
    if (_lastDistanceAnnouncement != null &&
        now.difference(_lastDistanceAnnouncement!).inSeconds <
            _minAnnouncementInterval) return;

    // Only announce at 0.5km/mile intervals
    if (roundedDistance % 0.5 == 0 && roundedDistance > 0) {
      final distanceText = roundedDistance == roundedDistance.round()
          ? roundedDistance.round().toString()
          : roundedDistance.toString();

      await speak("Distance: $distanceText $unit");
      _lastDistanceAnnouncement = now;
      _lastAnnouncedDistance = roundedDistance;
    }
  }

  // Pace feedback
  Future<void> announcePaceFeedback(
      double currentPace, double averagePace) async {
    if (!_settingsProvider.audioEnabled) return;

    final now = DateTime.now();
    if (_lastPaceAnnouncement != null &&
        now.difference(_lastPaceAnnouncement!).inSeconds <
            _minAnnouncementInterval) return;

    String message = "";

    // Compare current pace to average pace
    if (currentPace < averagePace * 0.8) {
      message = "Great pace! You're moving faster than your average.";
    } else if (currentPace > averagePace * 1.2) {
      message = "You're slowing down. Try to maintain your pace.";
    }

    if (message.isNotEmpty) {
      await speak(message);
      _lastPaceAnnouncement = now;
    }
  }

  // Time milestone announcements
  Future<void> announceTimeMilestone(Duration duration) async {
    if (!_settingsProvider.audioEnabled) return;

    final now = DateTime.now();
    final minutes = duration.inMinutes;

    // Check if we've already announced this minute or if it's too soon
    if (_lastAnnouncedMinute == minutes) return;
    if (_lastTimeAnnouncement != null &&
        now.difference(_lastTimeAnnouncement!).inSeconds <
            _minAnnouncementInterval) return;

    // Announce at 5-minute intervals
    if (minutes % 5 == 0 && minutes > 0) {
      final hours = duration.inHours;
      final remainingMinutes = minutes % 60;

      String timeText;
      if (hours > 0) {
        timeText = "$hours hour${hours > 1 ? 's' : ''}";
        if (remainingMinutes > 0) {
          timeText +=
              " and $remainingMinutes minute${remainingMinutes > 1 ? 's' : ''}";
        }
      } else {
        timeText = "$minutes minute${minutes > 1 ? 's' : ''}";
      }

      await speak("Time: $timeText");
      _lastTimeAnnouncement = now;
      _lastAnnouncedMinute = minutes;
    }
  }

  // Run state announcements
  Future<void> announceRunState(AudioCueType type) async {
    if (!_settingsProvider.audioEnabled) return;

    switch (type) {
      case AudioCueType.startRun:
        await speak("Run started. Good luck!");
        break;
      case AudioCueType.pauseRun:
        await speak("Run paused.");
        break;
      case AudioCueType.resumeRun:
        await speak("Run resumed.");
        break;
      case AudioCueType.endRun:
        await speak("Run completed. Great job!");
        break;
      default:
        break;
    }
  }

  // Chaser warnings
  Future<void> announceChaserWarning(String chaserName, double distance) async {
    if (!_settingsProvider.audioEnabled) return;

    String message = "";

    if (distance <= 10 && distance > 0) {
      message = "$chaserName is right behind you! Sprint!";
    } else if (distance <= 30 && distance > 10) {
      message = "$chaserName is closing in! Pick up the pace!";
    } else if (distance <= 50 && distance > 30) {
      message = "$chaserName is gaining on you!";
    } else if (distance == 0) {
      message = "$chaserName caught you! Try to break free!";
    }

    if (message.isNotEmpty) {
      await speak(message);
    }
  }

  // Power-up announcements
  Future<void> announcePowerUp(AudioCueType type, String powerUpName) async {
    if (!_settingsProvider.audioEnabled) return;

    switch (type) {
      case AudioCueType.powerUpActivated:
        await speak("$powerUpName activated!");
        break;
      case AudioCueType.powerUpExpired:
        await speak("$powerUpName expired.");
        break;
      default:
        break;
    }
  }

  // Achievement announcements
  Future<void> announceAchievement(String achievementName) async {
    if (!_settingsProvider.audioEnabled) return;

    await speak("Achievement unlocked: $achievementName");
  }

  void dispose() {
    _flutterTts.stop();
  }
}
