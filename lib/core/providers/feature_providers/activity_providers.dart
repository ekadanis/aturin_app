import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:aturin_app/core/services/api/activities/activity_api_service.dart';
import 'package:aturin_app/features/jadwal/services/aktivitas_service.dart';

/// Activity-related providers configuration
class ActivityProviders {
  static List<SingleChildWidget> getProviders() {
    return [
      // Activity API Service (Core data management)
      ChangeNotifierProvider<ActivityApiService>(
        create: (_) => ActivityApiService(),
      ),
      
      // Aktivitas Service (Business logic layer)
      ChangeNotifierProvider<AktivitasService>(
        create: (_) => AktivitasService(),
      ),
    ];
  }
}
