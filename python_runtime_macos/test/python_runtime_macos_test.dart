import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:python_runtime_macos/python_runtime_macos.dart';
import 'package:python_runtime_platform_interface/python_runtime_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PythonRuntimeMacOS', () {
    const kPlatformName = 'MacOS';
    late PythonRuntimeMacOS pythonRuntime;
    late List<MethodCall> log;

    setUp(() async {
      pythonRuntime = PythonRuntimeMacOS();

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
      PythonRuntimeMacOS.registerWith();
      expect(PythonRuntimePlatform.instance, isA<PythonRuntimeMacOS>());
    });

    test('getPlatformName returns correct name', () async {
      final name = await pythonRuntime.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(name, equals(kPlatformName));
    });

    test('createEnvironment executes successfully', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pythonRuntime.methodChannel, (methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'createEnvironment':
            return true;
          default:
            return null;
        }
      });

      final success = await pythonRuntime.createEnvironment();
      expect(
        log,
        <Matcher>[isMethodCall('createEnvironment', arguments: null)],
      );
      expect(success, isTrue);
    });
  });
}
