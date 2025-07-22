import Foundation
import PythonKit

@objc class Python5050Solver: NSObject {
    private static var isInitialized = false

    private static func initializePython() {
        guard !isInitialized else { return }

        // 1. Find the path to the bundled python-stdlib
        guard let stdLibPath = Bundle.main.path(forResource: "python-stdlib", ofType: nil) else {
            fatalError("Could not find python-stdlib in app bundle!")
        }
        print("🔍 Found python-stdlib at: \(stdLibPath)")

        // 2. Find the path to the embedded Python framework
        let pythonFrameworkPath = Bundle.main.privateFrameworksPath! + "/Python.framework/Python"
        guard FileManager.default.fileExists(atPath: pythonFrameworkPath) else {
            fatalError("Python dynamic library not found at expected path: \(pythonFrameworkPath)")
        }
        print("🔍 Found Python.framework at: \(pythonFrameworkPath)")

        // 3. Set environment variables
        let stdLibPathInsideFramework = Bundle.main.privateFrameworksPath! + "/Python.framework/lib/python3.14"
        setenv("PYTHONHOME", stdLibPathInsideFramework, 1)
        setenv("PYTHONPATH", stdLibPathInsideFramework, 1)
        print("🔍 Set PYTHONHOME and PYTHONPATH")

        // 4. Tell PythonKit to use the embedded Python
        PythonLibrary.use(path: pythonFrameworkPath)
        print("🔍 Set PythonLibrary for PythonKit")

        isInitialized = true
    }

    @objc static func find5050(withProbabilityMap probabilityMap: [String: Double]) -> [[Int]] {
        print("🔍 Python5050Solver: Starting 50/50 detection")
        print("🔍 Input map: \(probabilityMap)")

        // Initialize Python if not already done
        initializePython()

        // Set up Python path to include the bundled Python files
        let sys = Python.import("sys")
        if let resourcePath = Bundle.main.path(forResource: "Python", ofType: nil) {
            if !Array(sys.path).contains(PythonObject(resourcePath)) {
                sys.path.insert(0, PythonObject(resourcePath))
                print("🔍 Added custom Python scripts to sys.path")
            }
        } else {
            print("❌ Could not find Python resource path")
            return []
        }

        // Import the Python module and call the function
        let pyModule = Python.import("core.probabilistic_guesser")
        let pyResult = pyModule.find_5050_situations_from_dict(probabilityMap)

        // Convert the Python result to a Swift array
        if let swiftCells = Array(pyResult) as? [[Int]] {
            print("✅ Success: \(swiftCells)")
            return swiftCells
        } else {
            print("❌ Failed to parse Python result")
            return []
        }
    }
} 