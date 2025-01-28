import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:python_runtime_platform_interface/python_runtime_platform_interface.dart';
import 'package:python_runtime_windows/python_runtime_windows.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PythonRuntimeWindows', () {
    const kPlatformName = 'Windows';
    late PythonRuntimeWindows pythonRuntime;
    late List<MethodCall> log;

    setUp(() async {
      pythonRuntime = PythonRuntimeWindows();

      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pythonRuntime.methodChannel, (methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'getPlatformName':
            return kPlatformName;
          default:
            return null;
        }
      });
    });

    test('can be registered', () {
      PythonRuntimeWindows.registerWith();
      expect(PythonRuntimePlatform.instance, isA<PythonRuntimeWindows>());
    });

    test('getPlatformName returns correct name', () async {
      final name = await pythonRuntime.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(name, equals(kPlatformName));
    });
  });
}
