extension ArtifactBundleManifest {
    func path(for artifactName: String, targetTriple: String) throws -> String {
        guard let artifact = artifacts[artifactName] else {
            throw "Could not find an artifact named '\(artifactName)'"
        }

        guard let variant = artifact.variants.first(where: {
            $0.supportedTriples.contains(targetTriple)
        }) else {
            throw "Could not find an exectuable variant for the target triple '\(targetTriple)'"
        }

        return variant.path
    }
}
