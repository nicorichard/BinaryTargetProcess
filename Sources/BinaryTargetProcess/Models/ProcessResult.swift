import Foundation

public struct ProcessResult: Equatable {
    public let exitCode: Int32

    public init(exitCode: Int32) {
        self.exitCode = exitCode
    }

    /// Returns true if the process exited with code 0
    public var succeeded: Bool {
        exitCode == 0
    }

    /// Exits the current process with this result's exit code.
    /// Use for method chaining: `try process.run().exit()`
    public func exit() -> Never {
        Foundation.exit(exitCode)
    }

    /// Throws `ProcessExecutionError` if the exit code is non-zero
    public func throwIfFailed() throws {
        if exitCode != 0 {
            throw ProcessExecutionError(result: self)
        }
    }
}
