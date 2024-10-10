import Foundation

extension FileManager {
    private func findBundle(named bundleName: String, from startURL: URL) throws -> URL? {
        let artifactDirectoryContents = try contentsOfDirectory(at: startURL, includingPropertiesForKeys: nil)

        for item in artifactDirectoryContents {
            if item.lastPathComponent == bundleName {
                return item
            }
            if item.hasDirectoryPath {
                if let found = try findBundle(named: bundleName, from: item) {
                    return found
                }
            }
        }

        return nil
    }

    func findBundle(bundleName: String) throws -> URL {
        let artifactsPath = URL(fileURLWithPath: Bundle.main.bundlePath)
            .appending(path: "../../artifacts")

        guard let bundle = try findBundle(named: bundleName, from: artifactsPath) else {
            throw "Could not find artifact bundle named \(bundleName)"
        }

        return bundle
    }
}
