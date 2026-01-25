import XCTest
@testable import BinaryTargetProcess

final class RunnerTests: XCTestCase {
    private var fixturesBundlePath: URL {
        Bundle.module.resourceURL!.appendingPathComponent("Fixtures/exit-tool.artifactbundle")
    }

    private var signalToolBundlePath: URL {
        Bundle.module.resourceURL!.appendingPathComponent("Fixtures/signal-tool.artifactbundle")
    }

    func testRunReturnsZeroOnSuccess() async throws {
        let runner = try Runner(
            artifactName: "exit-tool",
            bundlePath: fixturesBundlePath,
            targetTriple: try TargetTriple.current()
        )

        let result = try await runner.run(arguments: ["0"])

        XCTAssertEqual(result.exitCode, 0)
        XCTAssertTrue(result.succeeded)
    }

    func testRunReturnsNonZeroOnFailure() async throws {
        let runner = try Runner(
            artifactName: "exit-tool",
            bundlePath: fixturesBundlePath,
            targetTriple: try TargetTriple.current()
        )

        let result = try await runner.run(arguments: ["1"])

        XCTAssertEqual(result.exitCode, 1)
        XCTAssertFalse(result.succeeded)
    }

    func testRunPropagatesArbitraryExitCode() async throws {
        let runner = try Runner(
            artifactName: "exit-tool",
            bundlePath: fixturesBundlePath,
            targetTriple: try TargetTriple.current()
        )

        let result = try await runner.run(arguments: ["42"])

        XCTAssertEqual(result.exitCode, 42)
    }

    // MARK: - ThrowIfFailed Tests

    func testThrowIfFailedDoesNotThrowOnSuccess() async throws {
        let runner = try Runner(
            artifactName: "exit-tool",
            bundlePath: fixturesBundlePath,
            targetTriple: try TargetTriple.current()
        )

        let result = try await runner.run(arguments: ["0"])

        XCTAssertNoThrow(try result.throwIfFailed())
    }

    func testThrowIfFailedThrowsOnFailure() async throws {
        let runner = try Runner(
            artifactName: "exit-tool",
            bundlePath: fixturesBundlePath,
            targetTriple: try TargetTriple.current()
        )

        let result = try await runner.run(arguments: ["1"])

        XCTAssertThrowsError(try result.throwIfFailed()) { error in
            guard let processError = error as? ProcessExecutionError else {
                XCTFail("Expected ProcessExecutionError")
                return
            }
            XCTAssertEqual(processError.exitCode, 1)
        }
    }

    // MARK: - Signal Forwarding Tests

    func testSignalForwardingSIGINT() async throws {
        let runner = try Runner(
            artifactName: "signal-tool",
            bundlePath: signalToolBundlePath,
            targetTriple: try TargetTriple.current()
        )

        // Start the async runner task
        let task = Task<ProcessResult, Error> {
            try await runner.run(arguments: ["60"])
        }

        // Give the process time to start
        try await Task.sleep(nanoseconds: 500_000_000)

        // Send SIGINT to our process (which should forward to child)
        kill(getpid(), SIGINT)

        let result = try await task.value
        XCTAssertEqual(result.exitCode, 130, "Child process should exit with 130 (128 + SIGINT)")
    }

    func testSignalForwardingSIGTERM() async throws {
        let runner = try Runner(
            artifactName: "signal-tool",
            bundlePath: signalToolBundlePath,
            targetTriple: try TargetTriple.current()
        )

        // Start the async runner task
        let task = Task<ProcessResult, Error> {
            try await runner.run(arguments: ["60"])
        }

        // Give the process time to start
        try await Task.sleep(nanoseconds: 500_000_000)

        // Send SIGTERM to our process (which should forward to child)
        kill(getpid(), SIGTERM)

        let result = try await task.value
        XCTAssertEqual(result.exitCode, 143, "Child process should exit with 143 (128 + SIGTERM)")
    }
}
