import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aturin_app/features/task/services/task_services.dart';
import 'package:aturin_app/features/home/services/task_service.dart' as home;

/// Router guard yang memastikan data diambil sebelum navigasi selesai
class DataPrefetchGuard extends AutoRouteGuard {
  @override
  Future<void> onNavigation(
    NavigationResolver resolver, 
    StackRouter router,
  ) async {
    final context = router.navigatorKey.currentContext;
    if (context != null) {
      if (resolver.route.name == 'HomeRoute') {
        await Provider.of<home.TaskService>(context, listen: false).fetchTasks();
      } else if (resolver.route.name == 'TaskListRoute') {
        await Provider.of<TaskService>(context, listen: false).fetchTasks();
      }
    }

    resolver.next(true);
  }
}