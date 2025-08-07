import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:aturin_app/features/home/services/home_service.dart';
import 'package:aturin_app/core/services/widgets/home_widget_provider.dart';

class HomeProviders {
  static List<SingleChildWidget> getProviders() {
    return [
      Provider<HomeService>(
        create: (_) => HomeService(),
      ),
      ChangeNotifierProvider<HomeWidgetProvider>(
        create: (_) => HomeWidgetProvider()..initialize(),
      ),
    ];
  }
}
