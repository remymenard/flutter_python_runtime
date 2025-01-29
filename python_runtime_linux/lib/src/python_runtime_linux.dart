import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:python_runtime_platform_interface/python_runtime_platform_interface.dart';

/// The Linux implementation of [PythonRuntimePlatform].
class PythonRuntimeLinux extends PythonRuntimePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('python_runtime_linux');

  /// Registers this class as the default instance of [PythonRuntimePlatform]
  static void registerWith() {
    PythonRuntimePlatform.instance = PythonRuntimeLinux();
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
