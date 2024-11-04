/// Decodes a `.artifactbundle`'s manifest as described by [SE-0305](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0305-swiftpm-binary-target-improvements.md)
struct ArtifactBundleManifest: Decodable {
    let schemaVersion: String
    let artifacts: [String: Artifact]

    struct Artifact: Decodable {
        let type: String
        let version: String
        let variants: [Variant]

        struct Variant: Decodable {
            let path: String
            let supportedTriples: [String]
        }
    }

    static var infoPath: String { "info.json" }
}
