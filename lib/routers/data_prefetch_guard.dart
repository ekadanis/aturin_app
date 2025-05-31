import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:aturin_app/features/home/services/home_service.dart' as home;
import 'package:aturin_app/core/services/api/task/task_service.dart';

/// Router guard yang memastikan data diambil sebelum navigasi selesai
class DataPrefetchGuard extends AutoRouteGuard {
  @override
  Future<void> onNavigation(
    NavigationResolver resolver, 
    StackRouter router,
  ) async {
    // Selalu izinkan navigasi di release mode untuk mencegah layar putih
    if (kReleaseMode) {
      // Di release mode, izinkan navigasi terlebih dahulu
      resolver.next(true);
      
      // Kemudian coba ambil data di background
      _fetchDataInBackground(resolver.route.name, router.navigatorKey.currentContext);
      return;
    }
    
    // Kode di bawah ini hanya dijalankan di debug mode
    final context = router.navigatorKey.currentContext;
    
    if (context != null) {
      try {
        if (resolver.route.name == 'HomeRoute') {
          await Provider.of<home.HomeService>(context, listen: false)
              .fetchData()
              .timeout(
                const Duration(seconds: 3),
                onTimeout: () {
                  debugPrint('HomeRoute data fetch timeout, continuing navigation');
                  return;
                },
              );
        } else if (resolver.route.name == 'TaskListRoute') {
          await TaskService()
              .getAllTasks()
              .timeout(
                const Duration(seconds: 3),
                onTimeout: () {
                  debugPrint('TaskListRoute data fetch timeout, continuing navigation');
                  return [];
                },
              );
        }
      } catch (e) {
        debugPrint('Error during data prefetch: $e');
      }
    }

    // Selalu lanjutkan navigasi bahkan jika prefetch gagal
    resolver.next(true);
  }
  
  // Metode untuk mengambil data di background tanpa menahan navigasi
  void _fetchDataInBackground(String routeName, BuildContext? context) {
    if (context == null) return;
    
    Future.microtask(() async {
      try {
        if (routeName == 'HomeRoute') {
          await Provider.of<home.HomeService>(context, listen: false)
              .fetchData()
              .timeout(const Duration(seconds: 5));
        } else if (routeName == 'TaskListRoute') {
          await TaskService()
              .getAllTasks()
              .timeout(const Duration(seconds: 5));
        }
      } catch (e) {
        debugPrint('Background data fetch error: $e');
      }
    });
  }
}