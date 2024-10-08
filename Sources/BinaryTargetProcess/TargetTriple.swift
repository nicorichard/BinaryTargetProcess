import Foundation

enum TargetTriple: String, CustomStringConvertible {
    case x86_64_macos = "x86_64-apple-macosx"
    case arm64_macos = "arm64-apple-macosx"
    case x86_64_linux = "x86_64-unknown-linux-gnu"
    case arm64_linux = "aarch64-unknown-linux-gnu"

    init() throws {
        #if arch(x86_64) && os(macOS)
            self = .x86_64_macos
        #elseif arch(arm64) && os(macOS)
            self = .arm64_macos
        #elseif arch(x86_64) && os(Linux)
            self = .x86_64_linux
        #elseif arch(arm64) && os(Linux)
            self = .arm64_linux
        #else
            throw "unsupported architecture / OS"
        #endif
    }

    var description: String {
        rawValue
    }
}
