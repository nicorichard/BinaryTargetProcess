import Foundation

struct Runner {
    let artifactName: String?
    let bundlePath: URL
    let targetTriple: TargetTriple

    private var artifactBundleManifestPath: URL {
        bundlePath.appendingPathComponent(ArtifactBundleManifest.infoPath)
    }

    private func readArtifactBundleManifest() throws -> ArtifactBundleManifest {
        let data = try Data(contentsOf: artifactBundleManifestPath)
        return try ArtifactBundleManifest.decode(from: data)
    }

    private func findToolPath(in manifest: ArtifactBundleManifest) throws -> URL {
        let path = try manifest.path(for: artifactName, targetTriple: targetTriple.rawValue)
        return bundlePath.appending(path: path)
    }

    public func run(arguments: [String]) throws {
        let process = Process()

        let manifest = try readArtifactBundleManifest()
        process.executableURL = try findToolPath(in: manifest)
        process.arguments = arguments

        try process.run()
        process.waitUntilExit()
    }
}
