// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// GENERATED_START
let vlcBinary = Target.binaryTarget(
	name: "VLCKitFull",
	url: "https://github.com/vvisionnn/swift-vlc/releases/download/3.5.1/VLCKitFull.xcframework.zip",
	checksum: "a27b8de4c9d7ea2b41b0b59ef6b3d97a729ff3d2884334a7162ab3c3fa8f8ef3"
)
// GENERATED_END

let package = Package(
	name: "swift-vlc",
	platforms: [.macOS(.v10_13), .iOS(.v11), .tvOS(.v11)],
	products: [
		.library(name: "SwiftVLC", targets: ["SwiftVLC"]),
	],
	targets: [
		vlcBinary,
		.target(
			name: "SwiftVLC",
			dependencies: [
				.target(name: "VLCKitFull"),
			], linkerSettings: [
				.linkedFramework("QuartzCore", .when(platforms: [.iOS])),
				.linkedFramework("CoreText", .when(platforms: [.iOS, .tvOS])),
				.linkedFramework("AVFoundation", .when(platforms: [.iOS, .tvOS])),
				.linkedFramework("Security", .when(platforms: [.iOS])),
				.linkedFramework("CFNetwork", .when(platforms: [.iOS])),
				.linkedFramework("AudioToolbox", .when(platforms: [.iOS, .tvOS])),
				.linkedFramework("OpenGLES", .when(platforms: [.iOS, .tvOS])),
				.linkedFramework("CoreGraphics", .when(platforms: [.iOS])),
				.linkedFramework("VideoToolbox", .when(platforms: [.iOS, .tvOS])),
				.linkedFramework("CoreMedia", .when(platforms: [.iOS, .tvOS])),
				.linkedLibrary("c++", .when(platforms: [.iOS, .tvOS])),
				.linkedLibrary("xml2", .when(platforms: [.iOS, .tvOS])),
				.linkedLibrary("z", .when(platforms: [.iOS, .tvOS])),
				.linkedLibrary("bz2", .when(platforms: [.iOS, .tvOS])),
				.linkedFramework("Foundation", .when(platforms: [.macOS])),
				.linkedLibrary("iconv"),
			]
		),
	]
)
