import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:python_runtime_platform_interface/src/method_channel_python_runtime.dart';

/// The interface that implementations of python_runtime must implement.
///
/// Platform implementations should extend this class
/// rather than implement it as `PythonRuntime`.
/// Extending this class (using `extends`) ensures that the subclass will get
/// the default implementation, while platform implementations that `implements`
///  this interface will be broken by newly added [PythonRuntimePlatform] methods.
abstract class PythonRuntimePlatform extends PlatformInterface {
  /// Constructs a PythonRuntimePlatform.
  PythonRuntimePlatform() : super(token: _token);

  static final Object _token = Object();

  static PythonRuntimePlatform _instance = MethodChannelPythonRuntime();

  /// The default instance of [PythonRuntimePlatform] to use.
  ///
  /// Defaults to [MethodChannelPythonRuntime].
  static PythonRuntimePlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [PythonRuntimePlatform] when they register themselves.
  static set instance(PythonRuntimePlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Return the current platform name.
  Future<String?> getPlatformName();

  Future<bool?> createEnvironment(String pythonVersion, String environmentName);
}
