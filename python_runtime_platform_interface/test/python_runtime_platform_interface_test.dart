import 'package:flutter_test/flutter_test.dart';
import 'package:python_runtime_platform_interface/python_runtime_platform_interface.dart';

class PythonRuntimeMock extends PythonRuntimePlatform {
  static const mockPlatformName = 'Mock';

  @override
  Future<String?> getPlatformName() async => mockPlatformName;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('PythonRuntimePlatformInterface', () {
    late PythonRuntimePlatform pythonRuntimePlatform;

    setUp(() {
      pythonRuntimePlatform = PythonRuntimeMock();
      PythonRuntimePlatform.instance = pythonRuntimePlatform;
    });

    group('getPlatformName', () {
      test('returns correct name', () async {
        expect(
          await PythonRuntimePlatform.instance.getPlatformName(),
          equals(PythonRuntimeMock.mockPlatformName),
        );
      });
    });
  });
}
