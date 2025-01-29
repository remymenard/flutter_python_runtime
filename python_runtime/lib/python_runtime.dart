import 'package:python_runtime_platform_interface/python_runtime_platform_interface.dart';

PythonRuntimePlatform get _platform => PythonRuntimePlatform.instance;

/// Returns the name of the current platform.
Future<String> getPlatformName() async {
  final platformName = await _platform.getPlatformName();
  if (platformName == null) throw Exception('Unable to get platform name.');
  return platformName;
}

/// Creates a Python environment using the current platform's method.
Future<bool?> createEnvironment(
    String pythonVersion, String environmentName) async {
  return _platform.createEnvironment(pythonVersion, environmentName);
}
