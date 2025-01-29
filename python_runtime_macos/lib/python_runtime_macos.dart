import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:python_runtime_platform_interface/python_runtime_platform_interface.dart';

/// The MacOS implementation of [PythonRuntimePlatform].
class PythonRuntimeMacOS extends PythonRuntimePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('python_runtime_macos');

  /// Registers this class as the default instance of [PythonRuntimePlatform]
  static void registerWith() {
    PythonRuntimePlatform.instance = PythonRuntimeMacOS();
  }

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }

  /// Creates a Python environment using micromamba
  @override
  Future<bool> createEnvironment(String pythonVersion, String environmentName) async {
    try {
      debugPrint('Creating Python environment');
      final result = await methodChannel.invokeMethod<bool>('createEnvironment', {
        'pythonVersion': pythonVersion,
        'environmentName': environmentName,
      });
      debugPrint('Result: $result');
      return result ?? false;
    } catch (e) {
      debugPrint('Error creating Python environment: $e');
      return false;
    }
  }
}
