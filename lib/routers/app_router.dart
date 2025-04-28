import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:aturin_app/features/home/ui/page/home_page.dart';
import 'package:aturin_app/features/profile/ui/profile_page.dart';
import 'package:aturin_app/features/profile/ui/profile_edit_page.dart';
import 'package:aturin_app/features/profile/models/user.dart';
import 'package:aturin_app/Test/task_page.dart';
import 'package:aturin_app/features/onboarding/ui/onboarding_screen.dart';
import 'package:aturin_app/features/animated_splash_screen/ui/animated_splash_screen.dart';
part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter{
  @override
  RouteType get defaultRouteType => RouteType.material(
    enablePredictiveBackGesture: true,
  );

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      path: '/',
      page: SplashRoute.page,
      initial: true,
    ),
    AutoRoute(
      path: '/onboarding',
      page: OnboardingRoute.page,
    ),
    
    CustomRoute(
      path: '/home',
      page: HomeRoute.page,
      transitionsBuilder: (_, __, ___, child) => child,
      duration: Duration.zero
    ),
    CustomRoute(
      path: '/profile',
      page: ProfileRoute.page,
      transitionsBuilder: (_, __, ___, child) => child,
      duration: Duration.zero
    ),
     CustomRoute(
      path: '/task',
      page: TaskRoute.page,
      transitionsBuilder: (_, __, ___, child) => child,
      duration: Duration.zero
    ),
    CustomRoute(
      path: '/profile/edit',
      page: ProfileEditRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      duration: Duration.zero
    ),
  ];
}