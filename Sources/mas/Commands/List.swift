//
// List.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Lists all apps currently installed on your Mac via the Mac App Store.
	///
	/// This command displays each app’s:
	/// - App Store ID
	/// - Name
	/// - Installed version
	///
	/// The output can be used to:
	/// - Identify installed apps
	/// - Verify App Store IDs for use with `mas upgrade`, `mas info`, or `mas uninstall`
	///
	/// Example:
	/// ```bash
	/// mas list
	/// ```
	///
	/// Output:
	/// ```
	/// 497799835 Xcode       (15.4)
	/// 640199958 Developer   (10.6.5)
	/// 899247664 TestFlight  (3.5.2)
	/// ```
	///
	/// > Tip:
	/// > If the output is unexpectedly empty, try resetting the Spotlight index:
	/// > ```bash
	/// > sudo mdutil -Eai on
	/// > ```
	///
	/// > Important:
	/// > This command relies on macOS Spotlight indexing to detect installed apps.
	/// > If some apps do not appear as expected, you may need to rebuild the metadata index:
	/// > ```bash
	/// > sudo mdutil -Eai on
	/// > ```
	/// > For details, see the [README Troubleshooting Section](https://github.com/mas-cli/mas#troubleshooting).
	struct List: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "List all apps installed from the Mac App Store"
		)

		/// Runs the command.
		func run() async throws {
			try run(installedApps: await installedApps)
		}

		func run(installedApps: [InstalledApp]) throws {
			try mas.run { run(printer: $0, installedApps: installedApps) }
		}

		private func run(printer: Printer, installedApps: [InstalledApp]) {
			if installedApps.isEmpty {
				printer.error(
					"""
					No installed apps found

					If this is unexpected, the following command line should fix it by
					(re)creating the Spotlight index (which might take some time):

					sudo mdutil -Eai on
					"""
				)
			} else {
				printer.info(AppListFormatter.format(installedApps))
			}
		}
	}
}
