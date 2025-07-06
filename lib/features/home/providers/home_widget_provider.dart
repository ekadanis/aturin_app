import 'package:flutter/foundation.dart';
import 'package:aturin_app/features/home/services/home_widget_service.dart';

/// Provider untuk mengelola state Home Widget
class HomeWidgetProvider extends ChangeNotifier {
  final HomeWidgetService _homeWidgetService = HomeWidgetService();
  
  bool _isInitialized = false;
  bool _isUpdating = false;
  DateTime? _lastUpdate;
  Map<String, dynamic>? _lastWidgetData;
  String? _error;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isUpdating => _isUpdating;
  DateTime? get lastUpdate => _lastUpdate;
  Map<String, dynamic>? get lastWidgetData => _lastWidgetData;
  String? get error => _error;

  /// Initialize home widget service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _error = null;
      await _homeWidgetService.initialize();
      _isInitialized = true;
      
      // Initial update
      await updateWidget();
      
      // Check for pending widget interactions
      await _processPendingInteractions();
      
      notifyListeners();
      debugPrint('🏠 HomeWidgetProvider: Initialized successfully');
    } catch (e) {
      _error = e.toString();
      debugPrint('🏠 HomeWidgetProvider: Initialization error: $e');
      notifyListeners();
    }
  }
  
  /// Process any pending widget interactions
  Future<void> _processPendingInteractions() async {
    try {
      final pendingAction = await _homeWidgetService.checkPendingInteractions();
      if (pendingAction != null) {
        debugPrint('🏠 HomeWidgetProvider: Processing pending action: $pendingAction');
        await _homeWidgetService.handleWidgetInteraction(pendingAction);
        
        // Set pending navigation request (akan diproses oleh HomePage)
        _pendingNavigation = pendingAction;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('🏠 HomeWidgetProvider: Error processing pending interactions: $e');
    }
  }
  
  // Pending navigation request
  String? _pendingNavigation;
  String? get pendingNavigation => _pendingNavigation;
  
  // Clear pending navigation after processed
  void clearPendingNavigation() {
    _pendingNavigation = null;
    notifyListeners();
  }

  /// Update widget dengan data terbaru
  Future<void> updateWidget() async {
    if (_isUpdating) return;
    
    try {
      _isUpdating = true;
      _error = null;
      notifyListeners();

      await _homeWidgetService.updateTodaySchedule();
      
      _lastUpdate = DateTime.now();
      _lastWidgetData = await _homeWidgetService.getWidgetData();
      
      debugPrint('🏠 HomeWidgetProvider: Widget updated successfully');
    } catch (e) {
      _error = e.toString();
      debugPrint('🏠 HomeWidgetProvider: Update error: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// Force refresh widget (untuk manual trigger)
  Future<void> forceRefresh() async {
    debugPrint('🏠 HomeWidgetProvider: Force refresh triggered');
    await updateWidget();
  }

  /// Update widget ketika ada perubahan data
  Future<void> onDataChanged() async {
    debugPrint('🏠 HomeWidgetProvider: Data changed, updating widget');
    await updateWidget();
  }

  /// Handle widget interaction
  Future<void> handleWidgetInteraction(String? action) async {
    await _homeWidgetService.handleWidgetInteraction(action);
  }

  /// Check if widget needs update (berdasarkan waktu)
  bool shouldUpdate() {
    if (_lastUpdate == null) return true;
    
    // Update setiap 15 menit
    final now = DateTime.now();
    final difference = now.difference(_lastUpdate!);
    return difference.inMinutes >= 15;
  }

  /// Auto update jika diperlukan
  Future<void> autoUpdateIfNeeded() async {
    if (shouldUpdate()) {
      debugPrint('🏠 HomeWidgetProvider: Auto update triggered');
      await updateWidget();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint('🏠 HomeWidgetProvider: Disposed');
  }
}
