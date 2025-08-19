import 'package:aturin_app/shared/core/constant/theme/app_theme.dart';
import 'package:aturin_app/shared/core/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


/// Widget untuk menampilkan error screen ketika terjadi kesalahan inisialisasi
/// Dipindahkan dari main.dart untuk struktur yang lebih clean
class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Aturin - Error',
          theme: AppTheme.lightTheme.copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.red,
              error: Colors.red,
            ),
          ),
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(4.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 10.h),
                    SizedBox(height: 2.h),
                    Text(
                      'Terjadi kesalahan saat memulai aplikasi. Uninstall dan install ulang aplikasi untuk memperbaiki masalah ini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _resetDatabase,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text('Reset Database'),
                        ),
                        SizedBox(width: 4.w),
                        ElevatedButton(
                          onPressed: _retryApp,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Reset database dan restart aplikasi
  Future<void> _resetDatabase() async {
    try {
      await DatabaseHelper.instance.resetDatabase();
      _retryApp();
    } catch (e) {
      debugPrint('ErrorApp: Error resetting database: $e');
    }
  }

  /// Restart aplikasi
  void _retryApp() {
    // Note: This would need to be connected to main() function
    // For now, we'll just show a debug message
    debugPrint('ErrorApp: Retry app requested');
  }
}
