import 'package:auto_route/auto_route.dart';
import 'package:aturin_app/Test/home_page.dart';
import 'package:aturin_app/Test/profile_page.dart';
import 'package:aturin_app/Test/task_page.dart';

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
    CustomRoute(
      path: '/',
      page: HomeRoute.page,
      initial: true,
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