import 'package:aturin_app/features/auth/password_reset/ui/password_reset_page.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:aturin_app/features/user_preference/ui/user_preference_page.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:aturin_app/features/home/ui/page/home_page.dart';
import 'package:aturin_app/features/profile/ui/profile_page.dart';
import 'package:aturin_app/features/profile/ui/profile_edit_page.dart';
import 'package:aturin_app/features/profile/models/user_model.dart';
import 'package:aturin_app/features/jadwal/screens/detail_task/ui/screens/task_detail_list_screen.dart';
import 'package:aturin_app/features/onboarding/ui/onboarding_screen.dart';
import 'package:aturin_app/features/animated_splash_screen/ui/animated_splash_screen.dart';
import 'package:aturin_app/features/task/screens/ui/task_list_screen.dart';
import 'package:aturin_app/features/task/screens/ui/add_task_screen.dart';
import 'package:aturin_app/features/task/model/task_model.dart';
import 'package:aturin_app/features/alarm/ui/screens/alarm_ringing_screen.dart';
import 'package:alarm/alarm.dart';
import 'package:aturin_app/routers/data_prefetch_guard.dart';
import 'package:aturin_app/features/jadwal/screens/aktivitas_screen/ui/aktivitas_screen.dart';
import 'package:aturin_app/features/jadwal/screens/add_aktivitas/ui/add_aktivitas.dart';
import 'package:aturin_app/features/jadwal/screens/detailactivity/ui/activity_detail_list.dart';
import 'package:aturin_app/features/auth/login/ui/login_page.dart';
import 'package:aturin_app/features/auth/register/ui/register_page.dart';
import 'package:aturin_app/features/no_internet/ui/no_internet_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  final dataPrefetchGuard = DataPrefetchGuard();

  @override
  RouteType get defaultRouteType =>
      RouteType.material(enablePredictiveBackGesture: true);
  @override
  List<AutoRoute> get routes => [
    AutoRoute(path: '/splash', page: SplashRoute.page, initial: true),
    AutoRoute(path: '/onboarding', page: OnboardingRoute.page),
    AutoRoute(path: '/login', page: LoginRoute.page),
    AutoRoute(path: '/register', page: RegisterRoute.page),
    AutoRoute(path: '/password_reset', page: PasswordResetRoute.page),

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
    // CustomRoute(
    //   path: '/task/detail',
    //   page: TaskDetailRoute.page,
    //   transitionsBuilder: (_, __, ___, child) => child,
    //   duration: Duration.zero,
    // ),
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
      path: '/aktivitas',
      page: AktivitasRoute.page,
      transitionsBuilder: (_, __, ___, child) => child,
      duration: Duration.zero,
    ),
    CustomRoute(
      path: '/aktivitas/add',
      page: AddAktivitasRoute.page,
      transitionsBuilder: (_, __, ___, child) => child,
      duration: Duration.zero,
    ),
    CustomRoute(
      path: '/aktivitas/activity-detail',
      page: ActivityDetailListRoute.page,
      transitionsBuilder: (_, __, ___, child) => child,
      duration: Duration.zero,
    ),
    CustomRoute(
      path: '/aktivitas/task-detail',
      page: TaskDetailListRoute.page,
      transitionsBuilder: (_, __, ___, child) => child,
      duration: Duration.zero,
    ),
    CustomRoute(
      path: '/no-internet',
      page: NoInternetRoute.page,
      transitionsBuilder: (_, __, ___, child) => child,
      duration: Duration.zero,
    ),
    CustomRoute(
      path: '/user_preference',
      page: UserPreferenceRoute.page,
      transitionsBuilder: (_, __, ___, child) => child,
      duration: Duration.zero,
    ),
  ];
}
