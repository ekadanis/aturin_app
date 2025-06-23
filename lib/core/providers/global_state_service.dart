import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aturin_app/features/task/model/task_model.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:aturin_app/features/profile/models/user_model.dart';
import 'package:aturin_app/core/services/api/task/task_api_service.dart';
import 'package:aturin_app/core/services/api/activities/activity_api_service.dart';
import 'package:aturin_app/core/services/api/profile/profile_service.dart';

/// Global State Service untuk mengelola data yang di-share antara screens
/// Mengatasi masalah loading redundant dan sinkronisasi data
class GlobalStateService extends ChangeNotifier {
  // Singleton pattern
  static final GlobalStateService _instance = GlobalStateService._internal();
  factory GlobalStateService() => _instance;
  GlobalStateService._internal();

  // API Services
  final TaskApiService _taskApiService = TaskApiService();
  final ActivityApiService _activityApiService = ActivityApiService();
  final ProfileService _profileService = ProfileService();

  // ============================
  // STATE VARIABLES
  // ============================
  
  // User data
  User? _currentUser;
  DateTime? _userLastFetched;
  
  // Tasks data
  List<Task> _allTasks = [];
  List<Task> _todayTasks = [];
  DateTime? _tasksLastFetched;
  
  // Activities data
  List<AktivitasModel> _allActivities = [];
  List<AktivitasModel> _todayActivities = [];
  DateTime? _activitiesLastFetched;
  
  // Loading states
  bool _isLoadingUser = false;
  bool _isLoadingTasks = false;
  bool _isLoadingActivities = false;
  
  // ============================
  // GETTERS
  // ============================
  
  User? get currentUser => _currentUser;
  List<Task> get allTasks => _allTasks;
  List<Task> get todayTasks => _todayTasks;
  List<AktivitasModel> get allActivities => _allActivities;
  List<AktivitasModel> get todayActivities => _todayActivities;
  
  bool get isLoadingUser => _isLoadingUser;
  bool get isLoadingTasks => _isLoadingTasks;
  bool get isLoadingActivities => _isLoadingActivities;
  bool get isLoading => _isLoadingUser || _isLoadingTasks || _isLoadingActivities;
  
  // Cache validation (5 minutes cache)
  bool get isUserCacheValid => _userLastFetched != null && 
    DateTime.now().difference(_userLastFetched!).inMinutes < 5;
  
  bool get isTasksCacheValid => _tasksLastFetched != null && 
    DateTime.now().difference(_tasksLastFetched!).inMinutes < 2;
    
  bool get isActivitiesCacheValid => _activitiesLastFetched != null && 
    DateTime.now().difference(_activitiesLastFetched!).inMinutes < 2;
  
  // ============================
  // COMPUTED PROPERTIES
  // ============================
  
  int get todayTasksCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return _allTasks.where((task) {
      final taskDate = DateTime(
        task.deadline.year,
        task.deadline.month,
        task.deadline.day,
      );
      return taskDate.isAtSameMomentAs(today) && 
             task.status != TaskStatus.completed;
    }).length;
  }
  
  int get todayActivitiesCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return _allActivities.where((aktivitas) {
      final aktivitasDate = DateTime(
        aktivitas.activityDate.year,
        aktivitas.activityDate.month,
        aktivitas.activityDate.day,
      );
      return aktivitasDate.isAtSameMomentAs(today);
    }).length;
  }
  
  // ============================
  // USER MANAGEMENT
  // ============================
  
  Future<User?> getUser({bool forceRefresh = false}) async {
    if (!forceRefresh && isUserCacheValid && _currentUser != null) {
      debugPrint('📋 GlobalStateService: Returning cached user data');
      return _currentUser;
    }
    
    if (_isLoadingUser) {
      debugPrint('📋 GlobalStateService: User already loading, waiting...');
      // Wait for current loading to complete
      while (_isLoadingUser) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _currentUser;
    }
    
    _isLoadingUser = true;
    notifyListeners();
    
    try {
      debugPrint('📋 GlobalStateService: Fetching fresh user data...');
      final user = await _profileService.getBannerProfile();
      
      if (user != null) {
        _currentUser = user;
        _userLastFetched = DateTime.now();
        debugPrint('✅ GlobalStateService: User data updated - ${user.name}');
      }
      
      return user;
    } catch (e) {
      debugPrint('❌ GlobalStateService: Error fetching user: $e');
      return _currentUser; // Return cached data on error
    } finally {
      _isLoadingUser = false;
      notifyListeners();
    }
  }
  
  // ============================
  // TASKS MANAGEMENT
  // ============================
  
  Future<List<Task>> getTasks({bool forceRefresh = false}) async {
    if (!forceRefresh && isTasksCacheValid && _allTasks.isNotEmpty) {
      debugPrint('📋 GlobalStateService: Returning cached tasks data');
      return _allTasks;
    }
    
    if (_isLoadingTasks) {
      debugPrint('📋 GlobalStateService: Tasks already loading, waiting...');
      while (_isLoadingTasks) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _allTasks;
    }
    
    _isLoadingTasks = true;
    notifyListeners();
    
    try {
      debugPrint('📋 GlobalStateService: Fetching fresh tasks data...');
      final tasks = await _taskApiService.getAllTasks();
      
      _allTasks = tasks;
      _updateTodayTasks();
      _tasksLastFetched = DateTime.now();
      
      debugPrint('✅ GlobalStateService: Tasks data updated - ${tasks.length} tasks');
      
      return tasks;
    } catch (e) {
      debugPrint('❌ GlobalStateService: Error fetching tasks: $e');
      return _allTasks; // Return cached data on error
    } finally {
      _isLoadingTasks = false;
      notifyListeners();
    }
  }
  
  Future<List<Task>> getTodayTasks({bool forceRefresh = false}) async {
    await getTasks(forceRefresh: forceRefresh);
    return _todayTasks;
  }
  
  void _updateTodayTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    _todayTasks = _allTasks.where((task) {
      final taskDate = DateTime(
        task.deadline.year,
        task.deadline.month,
        task.deadline.day,
      );
      return taskDate.isAtSameMomentAs(today);
    }).toList();
  }
  
  // ============================
  // ACTIVITIES MANAGEMENT
  // ============================
  
  Future<List<AktivitasModel>> getActivities({bool forceRefresh = false}) async {
    if (!forceRefresh && isActivitiesCacheValid && _allActivities.isNotEmpty) {
      debugPrint('📋 GlobalStateService: Returning cached activities data');
      return _allActivities;
    }
    
    if (_isLoadingActivities) {
      debugPrint('📋 GlobalStateService: Activities already loading, waiting...');
      while (_isLoadingActivities) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _allActivities;
    }
    
    _isLoadingActivities = true;
    notifyListeners();
    
    try {
      debugPrint('📋 GlobalStateService: Fetching fresh activities data...');
      final activities = await _activityApiService.getAllActivities();
      
      _allActivities = activities;
      _updateTodayActivities();
      _activitiesLastFetched = DateTime.now();
      
      debugPrint('✅ GlobalStateService: Activities data updated - ${activities.length} activities');
      
      return activities;
    } catch (e) {
      debugPrint('❌ GlobalStateService: Error fetching activities: $e');
      return _allActivities; // Return cached data on error
    } finally {
      _isLoadingActivities = false;
      notifyListeners();
    }
  }
  
  Future<List<AktivitasModel>> getTodayActivities({bool forceRefresh = false}) async {
    await getActivities(forceRefresh: forceRefresh);
    return _todayActivities;
  }
  
  void _updateTodayActivities() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    _todayActivities = _allActivities.where((aktivitas) {
      final aktivitasDate = DateTime(
        aktivitas.activityDate.year,
        aktivitas.activityDate.month,
        aktivitas.activityDate.day,
      );
      return aktivitasDate.isAtSameMomentAs(today);
    }).toList();
  }
  
  // ============================
  // DATA SYNCHRONIZATION METHODS
  // ============================
  
  /// Force refresh all data
  Future<void> refreshAllData() async {
    debugPrint('🔄 GlobalStateService: Force refreshing all data...');
    
    await Future.wait([
      getUser(forceRefresh: true),
      getTasks(forceRefresh: true),
      getActivities(forceRefresh: true),
    ]);
    
    debugPrint('✅ GlobalStateService: All data refreshed');
  }
  
  /// Call this when tasks are modified (create/update/delete)
  Future<void> onTasksChanged() async {
    debugPrint('🔄 GlobalStateService: Tasks changed - refreshing...');
    await getTasks(forceRefresh: true);
  }
  
  /// Call this when activities are modified (create/update/delete)
  Future<void> onActivitiesChanged() async {
    debugPrint('🔄 GlobalStateService: Activities changed - refreshing...');
    await getActivities(forceRefresh: true);
  }
  
  /// Call this when user profile is modified
  Future<void> onUserChanged() async {
    debugPrint('🔄 GlobalStateService: User changed - refreshing...');
    await getUser(forceRefresh: true);
  }
  
  // ============================
  // INITIALIZATION
  // ============================
  
  /// Initialize with cached data for instant UI
  Future<void> initialize() async {
    debugPrint('🚀 GlobalStateService: Initializing...');
    
    // Load all data in parallel for fast startup
    unawaited(Future.wait([
      getUser(),
      getTasks(),
      getActivities(),
    ]));
  }
  
  // ============================
  // CACHE MANAGEMENT
  // ============================
  
  void clearCache() {
    debugPrint('🗑️ GlobalStateService: Clearing all cache...');
    
    _currentUser = null;
    _userLastFetched = null;
    
    _allTasks.clear();
    _todayTasks.clear();
    _tasksLastFetched = null;
    
    _allActivities.clear();
    _todayActivities.clear();
    _activitiesLastFetched = null;
    
    notifyListeners();
  }
  
  @override
  void dispose() {
    // Singleton should not be disposed
    super.dispose();
  }
}

// Helper function for unawaited futures
void unawaited(Future future) {}
