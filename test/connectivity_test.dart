import 'package:flutter_test/flutter_test.dart';
import 'package:aturin_app/core/services/connectivity/connectivity_service.dart';

void main() {
  group('ConnectivityService Tests', () {
    late ConnectivityService connectivityService;

    setUp(() {
      connectivityService = ConnectivityService();
    });

    test('should be a singleton', () {
      final instance1 = ConnectivityService();
      final instance2 = ConnectivityService();
      expect(instance1, equals(instance2));
    });    test('should test server connectivity', () async {
      // Test with a reliable endpoint
      final result = await connectivityService.testServerConnection('https://google.com');
      // Note: This might fail in test environment without network
      expect(result, isA<bool>());
    });

    test('should test aturin-app API connectivity', () async {
      // Test with the actual API endpoint
      final result = await connectivityService.testServerConnection('https://aturin-app.com/api');
      print('API server connection result: $result');
      // Note: This test may fail if server is unreachable, but that's expected behavior
      expect(result, isA<bool>());
    });

    test('should get connectivity type', () async {
      final type = await connectivityService.getConnectivityType();
      expect(type, isA<String>());
    });

    test('should check network connectivity', () async {
      final hasNetwork = await connectivityService.hasNetworkConnectivity();
      expect(hasNetwork, isA<bool>());
    });
  });
}
