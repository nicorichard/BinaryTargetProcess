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

    public func run() throws {
        let runner = Runner(
            artifactName: artifactName,
            bundlePath: try fileManager.findBundle(
                bundleName: bundleName
            ),
            targetTriple: try TargetTriple()
        )

        try runner.run()
    }
}
