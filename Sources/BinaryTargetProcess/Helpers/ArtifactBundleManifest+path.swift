extension ArtifactBundleManifest {
    private func firstArtifactPath() throws -> (name: String, artifact: ArtifactBundleManifest.Artifact) {
        let availableKeys = Array(artifacts.keys).sorted()

        guard artifacts.count == 1 else {
            throw BinaryTargetProcessError.ambiguousArtifact(available: availableKeys)
        }

        guard let first = artifacts.first else {
            throw BinaryTargetProcessError.noArtifactFound
        }

        return (first.key, first.value)
    }

    private func artifactPath(named artifactName: String) throws -> (name: String, artifact: ArtifactBundleManifest.Artifact) {
        guard let artifact = artifacts[artifactName] else {
            let availableKeys = Array(artifacts.keys).sorted()
            throw BinaryTargetProcessError.artifactNotFound(name: artifactName, available: availableKeys)
        }

        return (artifactName, artifact)
    }

    func path(for artifactName: String?, targetTriple: String) throws -> String {
        let (resolvedName, artifact) = try artifactName.map { try artifactPath(named: $0) } ?? firstArtifactPath()

        guard let variant = artifact.variants.first(where: {
            $0.supportedTriples.contains(targetTriple)
        }) else {
            let availableTriples = artifact.variants.flatMap { $0.supportedTriples }.sorted()
            throw BinaryTargetProcessError.noMatchingVariant(
                artifactName: resolvedName,
                targetTriple: targetTriple,
                availableTriples: availableTriples
            )
        }

        return variant.path
    }
}
