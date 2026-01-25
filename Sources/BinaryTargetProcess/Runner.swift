import Foundation

struct Runner {
    let executableURL: URL

    init(executableURL: URL) {
        self.executableURL = executableURL
    }

    init(artifactName: String, bundlePath: URL, targetTriple: TargetTriple) throws {
        self.executableURL = try ManifestReader(
            artifactName: artifactName,
            bundlePath: bundlePath,
            targetTriple: targetTriple
        ).executableURL()
    }

    @discardableResult
    func run(
        arguments: [String],
        environment: [String: String]? = nil,
        inheritEnvironment: Bool = true
    ) async throws -> ProcessResult {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global().async {
                let process = Process()
                process.executableURL = executableURL
                process.arguments = arguments
                self.applyEnvironment(to: process, environment: environment, inheritEnvironment: inheritEnvironment)

                let signalQueue = DispatchQueue(label: "com.binarytargetprocess.signals")
                let forwarder = SignalForwarder.setup(for: process, queue: signalQueue)

                do {
                    try process.run()
                    process.waitUntilExit()
                    forwarder.cancel()

                    let result = ProcessResult(exitCode: process.terminationStatus)
                    continuation.resume(returning: result)
                } catch {
                    forwarder.cancel()
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func applyEnvironment(
        to process: Process,
        environment: [String: String]?,
        inheritEnvironment: Bool
    ) {
        if let environment = environment {
            if inheritEnvironment {
                var env = ProcessInfo.processInfo.environment
                env.merge(environment) { _, new in new }
                process.environment = env
            } else {
                process.environment = environment
            }
        }
    }
}

private struct SignalForwarder {
    let sigintSource: DispatchSourceSignal
    let sigtermSource: DispatchSourceSignal

    static func setup(for process: Process, queue: DispatchQueue) -> SignalForwarder {
        signal(SIGINT, SIG_IGN)
        signal(SIGTERM, SIG_IGN)

        let sigintSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: queue)
        sigintSource.setEventHandler { [weak process] in
            process?.interrupt()
        }
        sigintSource.resume()

        let sigtermSource = DispatchSource.makeSignalSource(signal: SIGTERM, queue: queue)
        sigtermSource.setEventHandler { [weak process] in
            process?.terminate()
        }
        sigtermSource.resume()

        return SignalForwarder(sigintSource: sigintSource, sigtermSource: sigtermSource)
    }

    func cancel() {
        sigintSource.cancel()
        sigtermSource.cancel()
        signal(SIGINT, SIG_DFL)
        signal(SIGTERM, SIG_DFL)
    }
}
