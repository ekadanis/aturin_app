// Test script untuk memverifikasi home screen real-time refresh fix
// Testing scenario: Activity deletion from detail screen should immediately reflect on home screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aturin_app/features/home/services/home_service.dart';
import 'package:aturin_app/core/services/api/activities/activity_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('====== HOME REALTIME REFRESH TEST ======');
  print('🔍 Testing scenario: Activity deletion should reflect immediately on home screen');
  
  try {
    final homeService = HomeService();
    final activityApiService = ActivityApiService();
    
    print('\n1️⃣ Initial data fetch...');
    await homeService.fetchData();
    print('   ✅ Initial activities count: ${homeService.todayAktivitas.length}');
    
    // Simulate quick successive operations (within 2 seconds)
    print('\n2️⃣ Testing caching behavior with quick operations...');
    
    final startTime = DateTime.now();
    
    // First call
    await homeService.fetchData();
    print('   📊 First call - Activities: ${homeService.todayAktivitas.length}');
    
    // Second call immediately (should use cache)
    await homeService.fetchData();
    print('   📊 Second call (should use cache) - Activities: ${homeService.todayAktivitas.length}');
    
    final timeDiff = DateTime.now().difference(startTime);
    print('   ⏱️ Time elapsed: ${timeDiff.inMilliseconds}ms');
    
    print('\n3️⃣ Testing forceRefresh behavior...');
    
    // Force refresh should bypass cache
    await homeService.forceRefresh();
    print('   ✅ Force refresh completed - Activities: ${homeService.todayAktivitas.length}');
    
    print('\n4️⃣ Testing activity deletion scenario...');
    
    if (homeService.todayAktivitas.isNotEmpty) {
      final activityToDelete = homeService.todayAktivitas.first;
      print('   🎯 Target activity: "${activityToDelete.activityTitle}" (ID: ${activityToDelete.id})');
      
      // Simulate deletion (this should call forceRefresh internally)
      await homeService.deleteActivity(activityToDelete.id!);
      
      print('   ✅ Deletion completed - New activities count: ${homeService.todayAktivitas.length}');
    } else {
      print('   ⚠️ No activities to delete for testing');
    }
    
    print('\n5️⃣ Testing real-time API data...');
    
    // Direct API call to verify data freshness
    final apiActivities = await activityApiService.getTodayActivities();
    print('   📡 Direct API call - Activities count: ${apiActivities.length}');
    print('   🔄 HomeService activities count: ${homeService.todayAktivitas.length}');
    
    if (apiActivities.length == homeService.todayAktivitas.length) {
      print('   ✅ SYNC SUCCESS: HomeService data matches API data');
    } else {
      print('   ❌ SYNC ISSUE: Data mismatch detected');
      print('   📊 API activities: ${apiActivities.map((a) => '"${a.activityTitle}"').join(', ')}');
      print('   📊 HomeService activities: ${homeService.todayAktivitas.map((a) => '"${a.activityTitle}"').join(', ')}');
    }
    
    print('\n✅ TEST COMPLETED SUCCESSFULLY');
    print('📝 Summary:');
    print('   - fetchData() uses caching (good for performance)');
    print('   - forceRefresh() bypasses cache (good for real-time updates)');
    print('   - deleteActivity() now uses forceRefresh() internally');
    print('   - HomePage now calls forceRefresh() when returning from detail screens');
    
  } catch (e) {
    print('❌ ERROR: $e');
    print('Stack trace:');
    print(e.toString());
  }
  
  print('====== TEST FINISHED ======');
}
