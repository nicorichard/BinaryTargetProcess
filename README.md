# BinaryTargetProcess

Include executable [Swift Package Manager (SPM) Artifact Bundles](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0305-swiftpm-binary-target-improvements.md#artifact-bundle) in your repository, allowing them to be `swift run` by anyone on your team — no additional tools required.

By depending on pre-built executables, the Swift tool can execute quickly without the need to resolve additional transitive dependencies or perform compilation.

This provides an alternative for those looking to move away from globally managed tooling (e.g. Homebrew) but are not ready too meet the constraints of Swift Plugins.

## Usage

1. **Create a new package folder** in your project to wrap the executable that you wish to use.

   > 💡 **Example**: Create a tooling package for your repository
   > ```bash
   > mkdir SwiftTools
   > cd SwiftTools
   > swift package init --name SwiftTools --type executable
   > ```

2. **Configure the binary target** you wish to execute (e.g. `swiftlint-binary`), and an executable target (`swiftlint`) to run it.

```swift
// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftTools",
    platforms: [.macOS(.v13)],
    products: [
        // Leave empty. This package can only be used with `swift run` and can not be distributed.
    ],
    dependencies: [
        .package(url: "https://github.com/nicorichard/BinaryTargetProcess", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "swiftlint",
            dependencies: ["swiftlint-binary", "BinaryTargetProcess"]
        ),
        .binaryTarget(
            name: "swiftlint-binary",
            url: "https://github.com/realm/SwiftLint/releases/download/0.57.0/SwiftLintBinary-macos.artifactbundle.zip", // Note: You may want to consider self-hosting your favourite artifacts
            checksum: "a1bbafe57538077f3abe4cfb004b0464dcd87e8c23611a2153c675574b858b3a"
        ),
    ]
)
```

3. **Add a source file** to launch the binary executable and pass all arguments (e.g. `SwiftTools/Sources/swiftlint/main.swift`)

```swift
import BinaryTargetProcess

try BinaryTargetProcess(
    artifactName: "swiftlint", // (optional) the name of the executable to be run
    bundleName: "SwiftLintBinary.artifactbundle" // the name of the unzipped artifactbundle
).run()
```

Now, anyone on your team with Swift installed can quickly and easily invoke SwiftLint:

```
swift run swiftlint
```

> Note: Use `--package-path SwiftTools` to run your tools from another directory
