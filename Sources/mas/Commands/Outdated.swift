//
//  Outdated.swift
//  mas
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import ArgumentParser

extension MAS {
	/// Command which displays a list of installed apps which have available updates
	/// ready to be installed from the Mac App Store.
	struct Outdated: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "List pending app updates from the Mac App Store"
		)

		@Flag(help: "Display warnings about apps unknown to the Mac App Store")
		var verbose = false

		/// Runs the command.
		func run() async throws {
			try await run(installedApps: await installedApps, searcher: ITunesSearchAppStoreSearcher())
		}

		func run(installedApps: [InstalledApp], searcher: AppStoreSearcher) async throws {
			for installedApp in installedApps {
				do {
					let storeApp = try await searcher.lookup(appID: installedApp.id)
					if installedApp.isOutdated(comparedTo: storeApp) {
						print(
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
				} catch MASError.unknownAppID(let unknownAppID) {
					if verbose {
						printWarning(
							"Identifier ",
							unknownAppID,
							" not found in store. Was expected to identify ",
							installedApp.name,
							".",
							separator: ""
						)
					}
				}
			}
		}
	}
}
