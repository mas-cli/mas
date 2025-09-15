private import Foundation
internal import PackagePlugin

@main
struct MASBuildToolPlugin: BuildToolPlugin {
	func createBuildCommands(context: PluginContext, target _: Target) -> [Command] {
		[
			.prebuildCommand(
				displayName: "Prebuild mas",
				executable: context.package.directoryURL.appendingPathComponent("Scripts/prebuild", isDirectory: false),
				arguments: [context.pluginWorkDirectoryURL.path],
				environment: ProcessInfo.processInfo.environment,
				outputFilesDirectory: context.pluginWorkDirectoryURL
			),
		]
	}
}
