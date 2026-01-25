import Foundation

public struct BinaryTargetProcess {
    let artifactName: String?
    let bundleName: String
    let fileManager: FileManager

    public init(
        artifactName: String? = nil,
        bundleName: String,
        fileManager: FileManager = .default
    ) {
        self.artifactName = artifactName
        self.bundleName = bundleName
        self.fileManager = fileManager
    }

    @discardableResult
    public func run(
        arguments: [String] = Array(CommandLine.arguments.dropFirst()),
        environment: [String: String]? = nil,
        inheritEnvironment: Bool = true
    ) async throws -> ProcessResult {
        let executableURL = try ManifestReader(
            artifactName: artifactName,
            bundlePath: try fileManager.findBundle(
                bundleName: bundleName
            ),
            targetTriple: try TargetTriple.current()
        ).executableURL()

        let runner = Runner(
            executableURL: executableURL
        )

        return try await runner.run(
            arguments: arguments,
            environment: environment,
            inheritEnvironment: inheritEnvironment
        )
    }
}
