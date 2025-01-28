import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:python_runtime/python_runtime.dart';
import 'package:python_runtime_platform_interface/python_runtime_platform_interface.dart';

class MockPythonRuntimePlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PythonRuntimePlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PythonRuntime', () {
    late PythonRuntimePlatform pythonRuntimePlatform;

    setUp(() {
      pythonRuntimePlatform = MockPythonRuntimePlatform();
      PythonRuntimePlatform.instance = pythonRuntimePlatform;
    });

    group('getPlatformName', () {
      test('returns correct name when platform implementation exists',
          () async {
        const platformName = '__test_platform__';
        when(
          () => pythonRuntimePlatform.getPlatformName(),
        ).thenAnswer((_) async => platformName);

        final actualPlatformName = await getPlatformName();
        expect(actualPlatformName, equals(platformName));
      });

      test('throws exception when platform implementation is missing',
          () async {
        when(
          () => pythonRuntimePlatform.getPlatformName(),
        ).thenAnswer((_) async => null);

        expect(getPlatformName, throwsException);
      });
    });
  });
}
