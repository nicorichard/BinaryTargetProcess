import Foundation

struct Runner {
    let artifactName: String
    let bundlePath: URL
    let targetTriple: TargetTriple

    private func readArtifactBundleManifest() throws -> ArtifactBundleManifest {
        let data = try Data(contentsOf: bundlePath.appending(path: ArtifactBundleManifest.infoPath))

        return try ArtifactBundleManifest.decode(from: data)
    }

    private func findToolPath() throws -> URL {
        let manifest = try readArtifactBundleManifest()
        let path = try manifest.path(for: artifactName, targetTriple: targetTriple.rawValue)

        return bundlePath.appending(path: path)
    }

    public func run() throws {
        let process = Process()

        process.executableURL = try findToolPath()
        process.arguments = Array(CommandLine.arguments.dropFirst())

        try process.run()
        process.waitUntilExit()
    }
}
