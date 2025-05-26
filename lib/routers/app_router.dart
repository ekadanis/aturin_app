import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:aturin_app/features/home/ui/page/home_page.dart';
import 'package:aturin_app/features/profile/ui/profile_page.dart';
import 'package:aturin_app/features/profile/ui/profile_edit_page.dart';
import 'package:aturin_app/features/profile/models/user.dart';
import 'package:aturin_app/features/onboarding/ui/onboarding_screen.dart';
import 'package:aturin_app/features/animated_splash_screen/ui/animated_splash_screen.dart';
import 'package:aturin_app/features/task/screens/screens/task_list_screen.dart';
import 'package:aturin_app/features/task/screens/screens/add_task_screen.dart';
import 'package:aturin_app/features/task/screens/screens/task_detail_screen.dart';
import 'package:aturin_app/features/task/model/task.dart';
import 'package:aturin_app/features/alarm/ui/screens/alarm_ringing_screen.dart';
import 'package:alarm/alarm.dart';
import 'package:aturin_app/routers/data_prefetch_guard.dart';
import 'package:aturin_app/features/schedule/screens/schedule_screen/ui/schedule_screen.dart';
import 'package:aturin_app/features/schedule/screens/add_schedule/ui/add_schedule.dart';
import 'package:aturin_app/features/schedule/screens/activity_detail_list.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  final dataPrefetchGuard = DataPrefetchGuard();

  @override
  RouteType get defaultRouteType =>
      RouteType.material(enablePredictiveBackGesture: true);

  @override
  List<AutoRoute> get routes => [
    AutoRoute(path: '/', page: SplashRoute.page, initial: true),
    AutoRoute(path: '/onboarding', page: OnboardingRoute.page),

    CustomRoute(
      path: '/home',
      page: HomeRoute.page,
      guards: [dataPrefetchGuard],
      transitionsBuilder: (_, __, ___, child) => child,
      duration: Duration.zero,
    ),
    CustomRoute(
      path: '/profile',
      page: ProfileRoute.page,
      transitionsBuilder: (_, __, ___, child) => child,
      duration: Duration.zero,
    ),
    CustomRoute(
      path: '/task',
      page: TaskListRoute.page,
      guards: [dataPrefetchGuard],
      transitionsBuilder: (_, __, ___, child) => child,
      duration: Duration.zero,
    ),
    CustomRoute(
      path: '/task/add',
      page: AddTaskRoute.page,
      transitionsBuilder: (_, __, ___, child) => child,
      duration: Duration.zero,
    ),
    CustomRoute(
      path: '/task/detail',
      page: TaskDetailRoute.page,
      transitionsBuilder: (_, __, ___, child) => child,
      duration: Duration.zero,
    ),
    CustomRoute(
      path: '/AlarmRinging',
      page: AlarmRingingRoute.page,
      transitionsBuilder: (_, __, ___, child) => child,
      duration: Duration.zero,
    ),
    CustomRoute(
      path: '/profile/edit',
      page: ProfileEditRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      duration: Duration.zero,
    ),
    CustomRoute(
      path: '/schedule',
      page: ScheduleRoute.page,
      transitionsBuilder: (_, __, ___, child) => child,
      duration: Duration.zero,
    ),
    CustomRoute(
      path: '/schedule/add',
      page: AddScheduleRoute.page,
      transitionsBuilder: (_, __, ___, child) => child,
      duration: Duration.zero,
    ),
    CustomRoute(
      path: '/schedule/activity-detail',
      page: ActivityDetailListRoute.page,
      transitionsBuilder: (_, __, ___, child) => child,
      duration: Duration.zero,
    ),
  ];
}
