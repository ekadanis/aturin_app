import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aturin_app/core/providers/provider_config.dart';
import 'package:aturin_app/core/services/connectivity/connectivity_service.dart';

/// Widget wrapper untuk mengatur semua Provider dalam aplikasi
/// Menggantikan MultiProvider setup yang sebelumnya ada di main.dart
class AppProviders extends StatelessWidget {
  final Widget child;
  final ConnectivityService connectivityService;
  
  const AppProviders({
    super.key,
    required this.child,
    required this.connectivityService,
  });
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: ProviderConfig.getProviders(
        connectivityService: connectivityService,
      ),
      child: child,
    );
  }
}

/// Wrapper sederhana untuk Provider inti saja
/// Digunakan jika hanya membutuhkan layanan inti
class CoreProviders extends StatelessWidget {
  final Widget child;
  final ConnectivityService connectivityService;
  
  const CoreProviders({
    super.key,
    required this.child,
    required this.connectivityService,
  });
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: ProviderConfig.getCoreProviders(
        connectivityService: connectivityService,
      ),
      child: child,
    );
  }
}

/// Extension untuk Provider context yang memudahkan akses ke service
extension ProviderExtensions on BuildContext {
  /// Mendapatkan GlobalStateService dari context
  T getService<T>() => Provider.of<T>(this, listen: false);
  
  /// Mendapatkan service dengan listen
  T watchService<T>() => Provider.of<T>(this, listen: true);
  
  /// Mendapatkan service dengan optional listen
  T readService<T>() => read<T>();
}
