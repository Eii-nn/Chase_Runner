import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  // Audio settings
  bool _audioEnabled = true;
  double _audioVolume = 0.8;
  String _voiceType = 'default';
  
  // UI settings
  bool _darkModeEnabled = false;
  String _distanceUnit = 'km'; // km or miles
  String _themeColor = 'blue';
  
  // Notification settings
  bool _notificationsEnabled = true;
  bool _milestoneNotifications = true;
  bool _weeklyRecapEnabled = true;
  
  // Privacy settings
  bool _shareRunData = false;
  bool _locationHistoryEnabled = true;
  
  // Getters
  bool get audioEnabled => _audioEnabled;
  double get audioVolume => _audioVolume;
  String get voiceType => _voiceType;
  bool get darkModeEnabled => _darkModeEnabled;
  String get distanceUnit => _distanceUnit;
  String get themeColor => _themeColor;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get milestoneNotifications => _milestoneNotifications;
  bool get weeklyRecapEnabled => _weeklyRecapEnabled;
  bool get shareRunData => _shareRunData;
  bool get locationHistoryEnabled => _locationHistoryEnabled;
  
  // Setters
  void setAudioEnabled(bool value) {
    _audioEnabled = value;
    notifyListeners();
  }
  
  void setAudioVolume(double value) {
    _audioVolume = value;
    notifyListeners();
  }
  
  void setVoiceType(String value) {
    _voiceType = value;
    notifyListeners();
  }
  
  void setDarkModeEnabled(bool value) {
    _darkModeEnabled = value;
    notifyListeners();
  }
  
  void setDistanceUnit(String value) {
    _distanceUnit = value;
    notifyListeners();
  }
  
  void setThemeColor(String value) {
    _themeColor = value;
    notifyListeners();
  }
  
  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }
  
  void setMilestoneNotifications(bool value) {
    _milestoneNotifications = value;
    notifyListeners();
  }
  
  void setWeeklyRecapEnabled(bool value) {
    _weeklyRecapEnabled = value;
    notifyListeners();
  }
  
  void setShareRunData(bool value) {
    _shareRunData = value;
    notifyListeners();
  }
  
  void setLocationHistoryEnabled(bool value) {
    _locationHistoryEnabled = value;
    notifyListeners();
  }
  
  // Load settings from storage
  void loadSettings() {
    // In a real app, load from shared preferences or other storage
  }
  
  // Save settings to storage
  void saveSettings() {
    // In a real app, save to shared preferences or other storage
  }
}

