import Foundation

public enum BinaryTargetProcessError: LocalizedError {
    case artifactsDirectoryNotFound
    case bundleNotFound(name: String)
    case noArtifactFound
    case ambiguousArtifact(available: [String])
    case artifactNotFound(name: String, available: [String])
    case noMatchingVariant(artifactName: String, targetTriple: String, availableTriples: [String])
    case manifestReadFailed(path: URL, underlying: Error)
    case unsupportedPlatform

    public var errorDescription: String? {
        switch self {
        case .artifactsDirectoryNotFound:
            return "Could not find artifacts directory"
        case .bundleNotFound(let name):
            return "Could not find artifact bundle named '\(name)'"
        case .noArtifactFound:
            return "Could not find any artifact"
        case .ambiguousArtifact(let available):
            return "The artifact bundle contains multiple artifacts (\(available.joined(separator: ", "))). Please specify `artifactName`."
        case .artifactNotFound(let name, let available):
            return "Could not find an artifact named '\(name)'. Available artifacts: \(available.joined(separator: ", "))"
        case .noMatchingVariant(let artifactName, let targetTriple, let availableTriples):
            return "Could not find an executable variant for artifact '\(artifactName)' matching target triple '\(targetTriple)'. Available triples: \(availableTriples.joined(separator: ", "))"
        case .manifestReadFailed(let path, let underlying):
            return "Failed to read artifact bundle manifest at '\(path.path)': \(underlying.localizedDescription)"
        case .unsupportedPlatform:
            return "Unsupported architecture / OS combination"
        }
    }
}
