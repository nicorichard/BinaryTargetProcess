import Foundation

public struct ProcessExecutionError: LocalizedError {
    public let result: ProcessResult

    public init(result: ProcessResult) {
        self.result = result
    }

    public var exitCode: Int32 {
        result.exitCode
    }

    public var errorDescription: String? {
        "Process exited with code \(exitCode)"
    }
}
