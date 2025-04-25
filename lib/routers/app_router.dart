import 'package:auto_route/auto_route.dart';
import 'package:aturin_app/Test/home_page.dart';
import 'package:aturin_app/Test/profile_page.dart';
import 'package:aturin_app/Test/task_page.dart';
import 'package:aturin_app/features/onboarding/ui/onboarding_screen.dart';
import 'package:aturin_app/features/splash_screen/ui/splash_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter{
  @override
  RouteType get defaultRouteType => RouteType.material(
    //Predictive Back Gesture?? Wowww!!!!
    //Ini cuma fitur animasi buat android 13+ doang sih, (menurutku keren)
    //kalau memang mau dipake jangan lupa tambahin
    //<activity android:enableOnBackInvokedCallback="true" ...> di android manifest
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
      path: '/task',
      page: TaskRoute.page,
      transitionsBuilder: (_, __, ___, child) => child,
      duration: Duration.zero
    ),
    CustomRoute(
      path: '/profile',
      page: ProfileRoute.page,
      transitionsBuilder: (_, __, ___, child) => child,
      duration: Duration.zero
    ),
  ];
}