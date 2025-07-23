import Flutter
import UIKit
import PythonKit
import Foundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let solverChannel = FlutterMethodChannel(name: "minesweeper/solver",
                                             binaryMessenger: controller.binaryMessenger)

    solverChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "find5050" {
        guard let args = call.arguments as? [String: Any],
              let probabilityMap = args["probabilityMap"] as? [String: Double] else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing probabilityMap", details: nil))
          return
        }
        // Set up Python path to include the bundled Python files
        let sys = Python.import("sys")
        if let resourcePath = Bundle.main.path(forResource: "Python", ofType: nil) {
          if !Array(sys.path).contains(PythonObject(resourcePath)) {
            sys.path.insert(0, PythonObject(resourcePath))
          }
        }
        // Import the Python module and call the function
        let pyModule = Python.import("core.probabilistic_guesser")
        let pyResult = pyModule.find_5050_situations_from_dict(probabilityMap)
        // Convert the Python result to a Swift array
        if let swiftCells = Array(pyResult) as? [[Int]] {
          result(swiftCells)
        } else {
          result(FlutterError(code: "PYTHON_ERROR", message: "Failed to parse Python result", details: nil))
        }
      } else {
        result(FlutterError(code: "NOT_IMPLEMENTED", message: "Method not implemented", details: nil))
      }
    })

    // GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
