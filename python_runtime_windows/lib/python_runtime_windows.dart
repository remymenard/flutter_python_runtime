import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:python_runtime_platform_interface/python_runtime_platform_interface.dart';

/// The Windows implementation of [PythonRuntimePlatform].
class PythonRuntimeWindows extends PythonRuntimePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('python_runtime_windows');

  /// Registers this class as the default instance of [PythonRuntimePlatform]
  static void registerWith() {
    PythonRuntimePlatform.instance = PythonRuntimeWindows();
  }

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }

  @override
  Future<bool?> createEnvironment(String pythonVersion, String environmentName) {
    return methodChannel.invokeMethod<bool>('createEnvironment', {
      'pythonVersion': pythonVersion,
      'environmentName': environmentName,
    });
  }
}
