import Foundation

extension ArtifactBundleManifest {
    static func decode(from data: Data) throws -> ArtifactBundleManifest {
        return try JSONDecoder().decode(Self.self, from: data)
    }
}
