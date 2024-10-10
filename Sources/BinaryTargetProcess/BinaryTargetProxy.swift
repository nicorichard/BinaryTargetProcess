import Foundation

public struct BinaryTargetProcess {
    let artifactName: String
    let bundlePath: URL
    let targetTriple: TargetTriple

    private func findToolPath() throws -> URL {
        let info = try ArtifactBundleManifest
            .decode(from: Data(contentsOf: bundlePath.appending(path: "info.json")))

        guard let artifact = info.artifacts[artifactName] else {
            throw "Could not find an artifact named '\(artifactName)'"
        }

        guard let variant = artifact.variants.first(where: {
            $0.supportedTriples.contains(targetTriple.rawValue)
        }) else {
            throw "Could not find an exectuable variant for the target triple '\(targetTriple)'"
        }

        return bundlePath
            .appending(path: variant.path)
    }

    public func run() throws {
        let process = Process()

        process.executableURL = try findToolPath()
        process.arguments = Array(CommandLine.arguments.dropFirst())

        try process.run()
        process.waitUntilExit()
    }
}

extension BinaryTargetProcess {
    public init(
        artifactName: String,
        bundleName: String,
        fileManager: FileManager = .default
    ) throws {
        self.init(
            artifactName: artifactName,
            bundlePath: try fileManager.findBundle(
                bundleName: bundleName
            ),
            targetTriple: try TargetTriple()
        )
    }
}
