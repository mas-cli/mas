//
// Outdated.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Lists apps installed via the Mac App Store that have available updates.
	///
	/// This command checks your installed apps against the latest versions available
	/// on the App Store using the public iTunes Search API.
	///
	/// The output shows the App ID, app name, current version, and latest version.
	///
	/// Example:
	/// ```bash
	/// mas outdated
	/// ```
	///
	/// Output:
	/// ```
	/// 497799835 Xcode     (15.4 -> 16.0)
	/// 640199958 Developer (10.6.5 -> 10.6.6)
	/// ```
	///
	/// > Tip:
	/// > Use this command before running `mas upgrade` to preview which apps will be updated.
	///
	/// > Note:
	/// > Use `--verbose` to print warnings about apps whose IDs are unknown to the Mac App Store.
	///
	/// See also:
	/// [iTunes Search API](https://performance-partners.apple.com/search-api)
	///
	/// > Important:
	/// > This command relies on macOS Spotlight indexing to detect installed apps.
	/// > If some apps do not appear as expected, you may need to rebuild the metadata index:
	/// > ```bash
	/// > sudo mdutil -Eai on
	/// > ```
	/// > For details, see the [README Troubleshooting Section](https://github.com/mas-cli/mas#troubleshooting).
	struct Outdated: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "List pending app updates from the Mac App Store"
		)

		@OptionGroup
		var verboseOptionGroup: VerboseOptionGroup

		/// Runs the command.
		func run() async throws {
			try await run(installedApps: await installedApps, searcher: ITunesSearchAppStoreSearcher())
		}

		func run(installedApps: [InstalledApp], searcher: AppStoreSearcher) async throws {
			try await mas.run { await run(printer: $0, installedApps: installedApps, searcher: searcher) }
		}

		private func run(printer: Printer, installedApps: [InstalledApp], searcher: AppStoreSearcher) async {
			for installedApp in installedApps {
				do {
					let storeApp = try await searcher.lookup(appID: installedApp.id)
					if installedApp.isOutdated(comparedTo: storeApp) {
						printer.info(
							installedApp.id,
							" ",
							installedApp.name,
							" (",
							installedApp.version,
							" -> ",
							storeApp.version,
							")",
							separator: ""
						)
					}
				} catch {
					verboseOptionGroup.printProblem(forError: error, expectedAppName: installedApp.name, printer: printer)
				}
			}
		}
	}
}
