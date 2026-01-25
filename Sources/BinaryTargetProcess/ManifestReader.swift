import Foundation

struct ManifestReader {
    let artifactName: String?
    let bundlePath: URL
    let targetTriple: TargetTriple
    
    var artifactBundleManifestPath: URL {
        bundlePath.appendingPathComponent(ArtifactBundleManifest.infoPath)
    }
    
    func readArtifactBundleManifest() throws -> ArtifactBundleManifest {
        do {
            let manifestData = try Data(contentsOf: artifactBundleManifestPath)
            return try ArtifactBundleManifest.decode(from: manifestData)
        } catch let error as BinaryTargetProcessError {
            throw error
        } catch {
            throw BinaryTargetProcessError.manifestReadFailed(path: artifactBundleManifestPath, underlying: error)
        }
    }

    func findToolPath(in manifest: ArtifactBundleManifest) throws -> URL {
        let path = try manifest.path(for: artifactName, targetTriple: targetTriple.rawValue)
        return bundlePath.appending(path: path)
    }
    
    func executableURL() throws -> URL {
        let manifest = try readArtifactBundleManifest()
        return try findToolPath(in: manifest)
    }
}
