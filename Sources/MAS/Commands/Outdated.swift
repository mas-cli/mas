//
// Outdated.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Outputs a list of installed apps which have updates available to be
	/// installed from the Mac App Store.
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
			try await MAS.run { await run(printer: $0, installedApps: installedApps, searcher: searcher) }
		}

		private func run(printer: Printer, installedApps: [InstalledApp], searcher: AppStoreSearcher) async {
			for installedApp in installedApps {
				do {
					let storeApp = try await searcher.lookup(appID: installedApp.id)
					if installedApp.isOutdated(comparedTo: storeApp) {
						printer.info(
							installedApp.adamID,
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
