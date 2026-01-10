// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HinglishVoice",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "HinglishVoice",
            targets: ["HinglishVoice"]
        ),
    ],
    dependencies: [
        // Pure Apple standard frameworks (Speech, NaturalLanguage, EventKit, AVFoundation)
    ],
    targets: [
        .target(
            name: "HinglishVoice",
            dependencies: [],
            path: "Sources/HinglishVoiceApp",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "HinglishVoiceTests",
            dependencies: ["HinglishVoice"],
            path: "Tests/HinglishVoiceAppTests"
        ),
    ]
)
