extension ArtifactBundleManifest {
    private func firstArtifactPath() throws -> ArtifactBundleManifest.Artifact {
        guard artifacts.count == 1 else {
            throw "The artifact bundle contains multiple artifacts. Please specify `artifactName`."
        }

        guard let artifact = artifacts.first?.value else {
            throw "Could not find any artifact."
        }

        return artifact
    }

    private func artifactPath(named artifactName: String) throws -> ArtifactBundleManifest.Artifact {
        guard let artifact = artifacts[artifactName] else {
            throw "Could not find an artifact named '\(artifactName)'"
        }

        return artifact
    }

    func path(for artifactName: String?, targetTriple: String) throws -> String {
        let artifact = try artifactName.map(artifactPath(named:)) ?? firstArtifactPath()

        guard let variant = artifact.variants.first(where: {
            $0.supportedTriples.contains(targetTriple)
        }) else {
            throw "Could not find an exectuable variant for the target triple '\(targetTriple)'"
        }

        return variant.path
    }
}
