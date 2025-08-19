import 'package:aturin_app/features/password_reset/presentation/screens/password_reset_page.dart';
import 'package:aturin_app/features/schedule/data/model/aktivitas_model.dart';
import 'package:aturin_app/features/user_preference/presentation/screens/user_preference_page.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:aturin_app/features/home/presentation/screens/home_page.dart';
import 'package:aturin_app/features/profile/presentation/screens/profile_page.dart';
import 'package:aturin_app/features/profile/presentation/screens/profile_edit_page.dart';
import 'package:aturin_app/features/profile/data/models/user_model.dart';
import 'package:aturin_app/features/schedule/presentation/screens/detail_task/ui/screens/task_detail_list_screen.dart';
import 'package:aturin_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:aturin_app/shared/screens/animated_splash_screen.dart';
import 'package:aturin_app/features/task/presentation/screens/task_list_screen.dart';
import 'package:aturin_app/features/task/presentation/screens/add_task_screen.dart';
import 'package:aturin_app/features/task/data/model/task_model.dart';
import 'package:aturin_app/features/alarm/presentation/screens/alarm_ringing_screen.dart';
import 'package:alarm/alarm.dart';
import 'package:aturin_app/shared/core/infrastructure/routers/data_prefetch_guard.dart';
import 'package:aturin_app/features/schedule/presentation/screens/aktivitas_screen/ui/aktivitas_screen.dart';
import 'package:aturin_app/features/schedule/presentation/screens/add_aktivitas/ui/add_aktivitas.dart';
import 'package:aturin_app/features/schedule/presentation/screens/detailactivity/ui/activity_detail_list.dart';
import 'package:aturin_app/features/login/presentation/screens/login_page.dart';
import 'package:aturin_app/features/register/presentation/screens/register_page.dart';
import 'package:aturin_app/shared/screens/no_internet_screen.dart';

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
