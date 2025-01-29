import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:python_runtime_platform_interface/python_runtime_platform_interface.dart';

/// An implementation of [PythonRuntimePlatform] that uses method channels.
class MethodChannelPythonRuntime extends PythonRuntimePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('python_runtime');

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }

  @override
  Future<bool?> createEnvironment(String pythonVersion, String environmentName) {
    return methodChannel.invokeMethod<bool>('createEnvironment');
  }
}
