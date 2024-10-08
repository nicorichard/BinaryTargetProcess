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
}

import Foundation

extension ArtifactBundleManifest {
    static func decode(from data: Data) throws -> ArtifactBundleManifest {
        return try JSONDecoder().decode(Self.self, from: data)
    }
}
