import Foundation

extension FileManager {

    /// Recursively searches directories starting at `origin` for a file exactly matching the name `fileName`
    private func findFile(named fileName: String, startingAt origin: URL) throws -> URL? {
        let artifactDirectoryContents = try contentsOfDirectory(at: origin, includingPropertiesForKeys: nil)

        for file in artifactDirectoryContents {
            if file.lastPathComponent == fileName {
                return file
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
        let spmArtifactsPath = URL(fileURLWithPath: Bundle.main.bundlePath)
            .appending(path: "../../artifacts")

        if fileExists(atPath: spmArtifactsPath.path) {
            return spmArtifactsPath
        }

        let xcodeArtifactsPath = URL(fileURLWithPath: Bundle.main.bundlePath)
            .appending(path: "../../../SourcePackages/artifacts")

        if fileExists(atPath: xcodeArtifactsPath.path) {
            return xcodeArtifactsPath
        }

        throw "Could not find artifacts directory"
    }

    /// Attempts to find the artifact bundle named `bundleName` from known artifact directory paths
    /// - Throws: If the artifact bundle cannot be found
    /// - Returns: The URL of the artifact bundle
    func findBundle(bundleName: String) throws -> URL {
        let artifactsPath = try findArtifactsPath()

        guard let bundle = try findFile(named: bundleName, startingAt: artifactsPath) else {
            throw "Could not find artifact bundle named \(bundleName)"
        }

        return bundle
    }
}
