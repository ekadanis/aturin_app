import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:aturin_app/core/services/api/task/task_api_service.dart';
import 'package:aturin_app/core/services/api/alarm/alarm_api_service.dart';


class TaskProviders {
  static List<SingleChildWidget> getProviders() {
    return [
      ChangeNotifierProvider<TaskApiService>(
        create: (_) => TaskApiService(),
      ),
      Provider<AlarmApiService>(
        create: (_) => AlarmApiService(),
      ),
    ];
  }
}
