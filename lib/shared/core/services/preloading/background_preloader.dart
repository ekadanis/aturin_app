import 'package:flutter/material.dart';
import 'package:aturin_app/shared/core/services/api/task/task_api_service.dart';
import 'package:aturin_app/shared/core/services/api/activities/activity_api_service.dart';
import 'package:aturin_app/shared/core/services/api/profile/profile_service.dart';

/// Service untuk menangani background preloading setelah aplikasi terbuka
class BackgroundPreloader extends ChangeNotifier {
  static final BackgroundPreloader _instance = BackgroundPreloader._internal();
  
  // Services
  final TaskApiService _taskApiService = TaskApiService();
  final ActivityApiService _activityApiService = ActivityApiService();
  final ProfileService _profileService = ProfileService();
  
  // Status flags
  bool _isPreloading = false;
  bool _isCompleted = false;
  bool _hasError = false;
  String? _errorMessage;
  double _progress = 0.0;
  
  // Public getters
  bool get isPreloading => _isPreloading;
  bool get isCompleted => _isCompleted;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  double get progress => _progress;
  
  // Singleton constructor
  factory BackgroundPreloader() {
    return _instance;
  }
  
  BackgroundPreloader._internal();
  
  /// Mulai background preloading setelah user masuk ke aplikasi
  Future<void> startBackgroundPreloading() async {
    // Jika sudah preloading atau sudah selesai, jangan lakukan lagi
    if (_isPreloading || _isCompleted) {
      return;
    }
    
    _isPreloading = true;
    _hasError = false;
    _errorMessage = null;
    _progress = 0.0;
    notifyListeners();
    
    
    try {
      // Memulai background preloading data
      
      // Load profile
      _updateProgress(0.1);
      await _preloadUserProfile();
      
      // Load tasks
      _updateProgress(0.4);
      await _preloadTasks();
      
      // Load activities
      _updateProgress(0.7);
      await _preloadActivities();
      
      // Selesai
      _isCompleted = true;
      _progress = 1.0;
      notifyListeners();
      
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isPreloading = false;
      notifyListeners();
    }
  }
  
  /// Preload profile data
  Future<void> _preloadUserProfile() async {
    try {
      await _profileService.me(forceRefresh: true);
    } catch (e) {
    }
  }
  
  /// Preload tasks data
  Future<void> _preloadTasks() async {
    try {
      await _taskApiService.fetchTasks(forceRefresh: true);
      await _taskApiService.fetchUncompletedTasksToday(forceRefresh: true);
    } catch (e) {
    }
  }
  
  /// Preload activities data
  Future<void> _preloadActivities() async {
    try {
      await _activityApiService.fetchActivities(forceRefresh: true);
    } catch (e) {
    }
  }
  
  /// Update progress dan notify listeners
  void _updateProgress(double value) {
    _progress = value;
    notifyListeners();
  }
  
  /// Reset status preloading (untuk testing atau reset manual)
  void reset() {
    _isPreloading = false;
    _isCompleted = false;
    _hasError = false;
    _errorMessage = null;
    _progress = 0.0;
    notifyListeners();
  }
}
