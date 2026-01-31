import Foundation

extension FileManager {

    /// Returns the directory containing the current executable
    private var executableDirectory: URL {
        // Prefer Bundle.main.executableURL as it's more reliable than bundlePath for CLI tools
        if let executableURL = Bundle.main.executableURL {
            return executableURL.deletingLastPathComponent()
        }
        // Fallback to CommandLine for Linux or edge cases
        return URL(fileURLWithPath: CommandLine.arguments[0])
            .deletingLastPathComponent()
    }

    /// Recursively searches directories starting at `origin` for a file exactly matching the name `fileName`
    private func findFile(named fileName: String, startingAt origin: URL) throws -> URL? {
        let artifactDirectoryContents = try contentsOfDirectory(at: origin, includingPropertiesForKeys: nil)

        for file in artifactDirectoryContents {
            if file.lastPathComponent == fileName {
                return file
            }
            if file.lastPathComponent == "__MACOSX" {
                continue
            }
            if file.hasDirectoryPath {
                if let found = try findFile(named: fileName, startingAt: file) {
                    return found
                }
            }
        }

        return nil
    }

    /// Attempts to discover the `artifacts` directory which should contain our binary target's executable
    ///  - Warning: This is a best-effort search and may not work in all cases
    ///  - Throws: If the artifacts directory cannot be found
    ///  - Returns: The URL of the artifacts directory
    private func findArtifactsPath() throws -> URL {
        let execDir = executableDirectory

        // SPM build directory: .build/debug/tool -> .build/artifacts
        let spmBuildArtifacts = execDir.appending(path: "../artifacts")
        if fileExists(atPath: spmBuildArtifacts.path) {
            return spmBuildArtifacts
        }

        // SPM `swift run`: Bundle.main.bundlePath resolves differently than executableURL
        let swiftRunArtifactsPath = URL(fileURLWithPath: Bundle.main.bundlePath)
            .appending(path: "../../artifacts")
        if fileExists(atPath: swiftRunArtifactsPath.path) {
            return swiftRunArtifactsPath
        }

        // Xcode SourcePackages
        let xcodeArtifactsPath = URL(fileURLWithPath: Bundle.main.bundlePath)
            .appending(path: "../../../SourcePackages/artifacts")
        if fileExists(atPath: xcodeArtifactsPath.path) {
            return xcodeArtifactsPath
        }

        throw BinaryTargetProcessError.artifactsDirectoryNotFound
    }

    /// Attempts to find the artifact bundle named `bundleName` from known artifact directory paths
    /// - Throws: If the artifact bundle cannot be found
    /// - Returns: The URL of the artifact bundle
    func findBundle(bundleName: String) throws -> URL {
        let artifactsPath = try findArtifactsPath()

        guard let bundle = try findFile(named: bundleName, startingAt: artifactsPath) else {
            throw BinaryTargetProcessError.bundleNotFound(name: bundleName)
        }

        return bundle
    }
}
