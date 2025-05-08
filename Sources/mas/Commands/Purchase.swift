//
// Purchase.swift
// mas
//
// Created by Jakob Rieck on 2017-10-24.
// Copyright © 2017 Jakob Rieck. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// "Purchases" & installs free apps from the Mac App Store.
	struct Purchase: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "\"Purchase\" & install free apps from the Mac App Store"
		)

		@OptionGroup
		var appIDsOptionGroup: AppIDsOptionGroup

		/// Runs the command.
		func run() async throws {
			try await run(installedApps: await installedApps, searcher: ITunesSearchAppStoreSearcher())
		}

		func run(installedApps: [InstalledApp], searcher: AppStoreSearcher) async throws {
			do {
				try await downloadApps(
					withAppIDs: appIDsOptionGroup.appIDs.filter { appID in
						if let appName = installedApps.first(where: { $0.id == appID })?.name {
							printWarning(appName, "has already been purchased")
							return false
						}
						return true
					},
					verifiedBy: searcher,
					purchasing: true
				)
			} catch {
				throw MASError(downloadFailedError: error)
			}
		}
	}
}
