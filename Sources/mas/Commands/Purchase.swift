//
// Purchase.swift
// mas
//
// Created by Jakob Rieck on 2017-10-24.
// Copyright © 2017 Jakob Rieck. All rights reserved.
//

import ArgumentParser
import Foundation

extension MAS {
	struct Purchase: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "\"Purchase\" and install free apps from the Mac App Store"
		)

		@Argument(help: ArgumentHelp("App ID", valueName: "app-id"))
		var appIDs: [AppID]

		/// Runs the command.
		func run() async throws {
			try await run(installedApps: await installedApps, searcher: ITunesSearchAppStoreSearcher())
		}

		func run(installedApps: [InstalledApp], searcher: AppStoreSearcher) async throws {
			do {
				try await downloadApps(
					withAppIDs: appIDs.filter { appID in
						if let appName = installedApps.first(where: { $0.id == appID })?.name {
							printWarning(appName, "has already been purchased.")
							return false
						}
						return true
					},
					verifiedBy: searcher,
					purchasing: true
				)
			} catch let error as MASError {
				throw error
			} catch {
				throw MASError.downloadFailed(error: error as NSError)
			}
		}
	}
}
