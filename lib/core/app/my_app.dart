import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:aturin_app/features/no_internet/ui/no_internet_screen.dart';
import '../providers/index.dart';
import '../services/connectivity/connectivity_service.dart';
import '../theme/app_theme.dart';
import '../../routers/app_router.dart';

class MyApp extends StatefulWidget {
  final ConnectivityService connectivityService;
  final AppRouter appRouter;

  const MyApp({
    super.key,
    required this.connectivityService,
    required this.appRouter,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return AppProviders(
      connectivityService: widget.connectivityService,
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return Consumer<ConnectivityService>(
            builder: (context, connectivity, _) {
              if (!connectivity.isConnected) {
                return const MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: NoInternetScreen(),
                );
              }

              return MaterialApp.router(
                title: 'Aturin',
                theme: AppTheme.lightTheme,
                debugShowCheckedModeBanner: false,
                routerConfig: widget.appRouter.config(),
              );
            },
          );
        },
      ),
    );
  }
}
