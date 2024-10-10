import Foundation

extension FileManager {
    func findBundle(targetName: String, bundleName: String) throws -> URL {
        let artifactsPath = URL(fileURLWithPath: Bundle.main.bundlePath)
            .appending(path: "../../artifacts")

        let artifactDirectoryContents = try subpathsOfDirectory(atPath: artifactsPath.relativePath)

        for directory in artifactDirectoryContents {
            if directory.hasSuffix("/\(targetName)/\(bundleName)") {
                return artifactsPath.appending(path: directory)
            }
        }

        throw "Could not find artifact bundle named \(bundleName)"
    }
}
