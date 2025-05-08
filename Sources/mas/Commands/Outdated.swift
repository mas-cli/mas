//
// Outdated.swift
// mas
//
// Created by Andrew Naylor on 2015-08-21.
// Copyright © 2015 Andrew Naylor. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Command which displays a list of installed apps which have available updates
	/// ready to be installed from the Mac App Store.
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
			for installedApp in installedApps {
				do {
					let storeApp = try await searcher.lookup(appID: installedApp.id)
					if installedApp.isOutdated(comparedTo: storeApp) {
						printInfo(
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
				} catch let MASError.unknownAppID(unknownAppID) {
					if verboseOptionGroup.verbose {
						printWarning("App ID", unknownAppID, "not found in store. Was expected to identify", installedApp.name)
					}
				}
			}
		}
	}
}
