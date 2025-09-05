private import Foundation
internal import PackagePlugin

@main
struct MASBuildToolPlugin: BuildToolPlugin {
	func createBuildCommands(context: PluginContext, target _: Target) -> [Command] {
		[
			.prebuildCommand(
				displayName: "Prebuild mas",
				executable: context.package.directory.appending("Scripts", "prebuild"),
				arguments: [context.pluginWorkDirectory.string],
				environment: ProcessInfo.processInfo.environment,
				outputFilesDirectory: context.pluginWorkDirectory
			),
		]
	}
}
