import Foundation

enum BundleNotFoundError: Error {
    case notFound
}

func findBundle(fileManager: FileManager = .default, targetName: String, bundleName: String) throws -> URL {
    let artifactsPath = URL(fileURLWithPath: Bundle.main.bundlePath)
        .appending(path: "../../artifacts")

    let artifactDirectoryContents = try fileManager.subpathsOfDirectory(atPath: artifactsPath.relativePath)

    for directory in artifactDirectoryContents {
        if directory.hasSuffix("/\(targetName)/\(bundleName)") {
            return artifactsPath.appending(path: directory)
        }
    }

    throw "Could not find the artifact bundle"
}
