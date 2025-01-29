import FlutterMacOS
import Foundation

public class PythonRuntimePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "python_runtime",
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
      downloadMicromamba { success in
        result(success)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func downloadMicromamba(completion: @escaping (Bool) -> Void) {
    // Get the bundle for this plugin
    let bundle = Bundle(for: PythonRuntimePlugin.self)
    debugPrint("Plugin bundle path: \(bundle.bundlePath)")
    
    // List all resources in the plugin bundle
    if let resources = bundle.urls(forResourcesWithExtension: nil, subdirectory: nil) {
        debugPrint("Resources in plugin bundle:")
        resources.forEach { debugPrint("- \($0.path)") }
    }
    
    // Get the resource bundle
    guard let resourceBundleURL = bundle.url(forResource: "python_runtime_macos_resources", withExtension: "bundle") else {
        debugPrint("Could not find resource bundle URL")
        completion(false)
        return
    }
    debugPrint("Resource bundle URL: \(resourceBundleURL.path)")
    
    guard let resourceBundle = Bundle(url: resourceBundleURL) else {
        debugPrint("Could not create bundle from URL: \(resourceBundleURL.path)")
        completion(false)
        return
    }
    debugPrint("Resource bundle path: \(resourceBundle.bundlePath)")
    
    // List all resources in the resource bundle
    if let bundleResources = resourceBundle.urls(forResourcesWithExtension: nil, subdirectory: nil) {
        debugPrint("Resources in resource bundle:")
        bundleResources.forEach { debugPrint("- \($0.path)") }
    }
    
    guard let micromambaURL = resourceBundle.url(forResource: "micromamba", withExtension: nil, subdirectory: "micromamba/bin") else {
        debugPrint("Could not find micromamba in resource bundle")
        debugPrint("Tried subdirectory: micromamba/bin")
        
        // Try listing contents of micromamba directory if it exists
        if let micromambaDir = resourceBundle.url(forResource: nil, withExtension: nil, subdirectory: "micromamba")?.path,
           FileManager.default.fileExists(atPath: micromambaDir) {
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: micromambaDir)
                debugPrint("Contents of micromamba directory:")
                contents.forEach { debugPrint("- \($0)") }
            } catch {
                debugPrint("Error listing micromamba directory: \(error)")
            }
        } else {
            debugPrint("micromamba directory not found in resource bundle")
        }
        
        completion(false)
        return
    }
    
    debugPrint("Bundle micromamba path: \(micromambaURL.path)")
    
    let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    let micromambaDir = appSupportURL.appendingPathComponent("micromamba")
    let micromambaPath = micromambaDir.appendingPathComponent("bin/micromamba")
    
    debugPrint("Target micromamba path: \(micromambaPath.path)")
    
    // Check if micromamba already exists in app support
    if FileManager.default.fileExists(atPath: micromambaPath.path) {
        debugPrint("Micromamba already exists in app support")
        completion(true)
        return
    }
    
    // Create directory if it doesn't exist
    do {
        try FileManager.default.createDirectory(at: micromambaDir.appendingPathComponent("bin"), withIntermediateDirectories: true)
        
        // Copy micromamba from bundle to app support
        if FileManager.default.fileExists(atPath: micromambaURL.path) {
            try FileManager.default.copyItem(at: micromambaURL, to: micromambaPath)
            try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: micromambaPath.path)
            debugPrint("Successfully copied micromamba to app support")
            completion(true)
        } else {
            debugPrint("Error: Micromamba not found in bundle at \(micromambaURL.path)")
            completion(false)
        }
    } catch {
        debugPrint("Error setting up micromamba: \(error)")
        completion(false)
    }
  }
}
