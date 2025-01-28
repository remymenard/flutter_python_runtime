import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:python_runtime_linux/python_runtime_linux.dart';
import 'package:python_runtime_platform_interface/python_runtime_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PythonRuntimeLinux', () {
    const kPlatformName = 'Linux';
    late PythonRuntimeLinux pythonRuntime;
    late List<MethodCall> log;

    setUp(() async {
      pythonRuntime = PythonRuntimeLinux();

      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pythonRuntime.methodChannel, (methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'getPlatformName':
            return kPlatformName;
          case 'createEnvironment':
            return true;
          default:
            return null;
        }
      });
    });

    test('can be registered', () {
      PythonRuntimeLinux.registerWith();
      expect(PythonRuntimePlatform.instance, isA<PythonRuntimeLinux>());
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
