# BinaryTargetProcess

Include executable SPM artifact bundles in your repository, allowing them to be run by anyone on your team using `swift run` without any additional tools required.

By depending on pre-built executables the swift tool can be run quickly, without necessitating resolving additonal transitive dependencies and compilation.

An alternative for those wanting to move away from globally managed tooling (e.g. Homebrew), but where Swift Plugins are inadequate.

## Usage

1. Create a new package folder in your project which will serve to wrap the executable that you wish to use.

> 💡 e.g Create a tooling package for your repository
> - `mkdir SwiftTools`
> - `cd SwiftTools`
> - `swift package init --name SwiftTools --type executable`

2. Configure the binary target you wish to execute (`swiftlint-binary`), and an executable target (`swiftlint`) from which to do it.

```swift
// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftTools",
    platforms: [.macOS(.v13)],
    products: [],
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

3. Add a single source file to launch the binary executable and pass all arguments (`SwiftTools/Sources/swiftlint/main.swift`)

```swift
import BinaryTargetProcess

try BinaryTargetProcess(
    artifactName: "swiftlint", // the name of the executable contained in the artifact bundle
    bundleName: "SwiftLintBinary.artifactbundle" // the name of the artifactbundle (after unzipping)
).run()
```

Now anyone on your team with swift on their machine can quickly invoke SwiftLint

```
swift run swiftlint
```

> Note: Use `--package-path SwiftTools` to run your tools from another directory
