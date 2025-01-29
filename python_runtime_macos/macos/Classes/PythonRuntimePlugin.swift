import FlutterMacOS
import Foundation

public class PythonRuntimePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "python_runtime_macos",
      binaryMessenger: registrar.messenger)
    let instance = PythonRuntimePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformName":
      result("MacOS")
    case "createEnvironment":
      debugPrint("Creating Python environment")
      guard let args = call.arguments as? [String: Any],
            let pythonVersion = args["pythonVersion"] as? String,
            let environmentName = args["environmentName"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENTS",
                             message: "Missing or invalid arguments",
                             details: nil))
          return
      }
      createEnvironment(pythonVersion: pythonVersion, environmentName: environmentName) { success in
          result(success)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func createEnvironment(pythonVersion: String, environmentName: String, completion: @escaping (Bool) -> Void) {
    // Get the bundle for this plugin
    let bundle = Bundle(for: type(of: self))
    
    // Get the path to the App.framework, which contains the Flutter assets
    let bundleURL = bundle.bundleURL.deletingLastPathComponent()
    guard let appFrameworkBundle = Bundle(url: bundleURL.appendingPathComponent("App.framework")) else {
        debugPrint("Failed to find App.framework bundle")
        completion(false)
        return
    }
    
    // Get the path to the micromamba binary in the Flutter assets
    let searchPath = "flutter_assets/packages/python_runtime_macos/assets"
    debugPrint("Searching for micromamba in bundle: \(appFrameworkBundle.bundlePath)")
    debugPrint("Looking in directory: \(searchPath)")
    
    guard let micromambaPath = appFrameworkBundle.path(forResource: "micromamba", ofType: nil, inDirectory: searchPath) else {
        debugPrint("Failed to find micromamba binary")
        // List the contents of the bundle to help debug
        if let enumerator = FileManager.default.enumerator(atPath: appFrameworkBundle.bundlePath) {
            debugPrint("Bundle contents:")
            while let filePath = enumerator.nextObject() as? String {
                debugPrint("  \(filePath)")
            }
        }
        completion(false)
        return
    }
    
    debugPrint("Found micromamba at: \(micromambaPath)")
    
    // Make sure micromamba is executable
    let fileManager = FileManager.default
    try? fileManager.setAttributes([.posixPermissions: 0o755], ofItemAtPath: micromambaPath)
    
    // Create a process to run micromamba
    let process = Process()
    process.executableURL = URL(fileURLWithPath: micromambaPath)
    
    // Set up environment variables
    let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
    let micromambaRoot = "\(homeDir)/.micromamba"
    
    // Create micromamba root directory if it doesn't exist
    try? fileManager.createDirectory(atPath: micromambaRoot, withIntermediateDirectories: true)
    
    var env = ProcessInfo.processInfo.environment
    env["MAMBA_ROOT_PREFIX"] = homeDir
    env["MAMBA_EXE"] = micromambaPath
    process.environment = env
    
    // Set up the arguments for creating the environment
    process.arguments = [
        "create",
        "-n", environmentName,
        "-c", "conda-forge",
        "python=\(pythonVersion)",
        "-y",
        "--root-prefix", homeDir
    ]
    
    // Set up pipes for output
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe
    
    // Launch the process
    do {
        try process.run()
        process.waitUntilExit()
        
        let status = process.terminationStatus
        if status == 0 {
            debugPrint("Successfully created Python environment")
            completion(true)
        } else {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorOutput = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            debugPrint("Failed to create Python environment: \(errorOutput)")
            completion(false)
        }
    } catch {
        debugPrint("Failed to run micromamba: \(error)")
        completion(false)
    }
  }
}
