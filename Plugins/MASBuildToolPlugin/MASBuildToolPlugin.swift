//
// MASBuildToolPlugin.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

private import Foundation
internal import PackagePlugin

@main
struct MASBuildToolPlugin: BuildToolPlugin {
	func createBuildCommands(context: PluginContext, target _: any Target) -> [Command] {
		[
			.prebuildCommand(
				displayName: "Prebuild mas",
				executable: context.package.directoryURL.appending(path: "Scripts/prebuild", directoryHint: .notDirectory),
				arguments: [
					{ url in
						unsafe url.withUnsafeFileSystemRepresentation { unsafe $0.map(String.init(cString:)) }
						?? url.path(percentEncoded: false) // swiftformat:disable:this indent
					}(context.pluginWorkDirectoryURL),
				],
				environment: ProcessInfo.processInfo.environment,
				outputFilesDirectory: context.pluginWorkDirectoryURL,
			),
		]
	}
}
