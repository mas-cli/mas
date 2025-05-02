//
// Install.swift
// mas
//
// Created by Andrew Naylor on 2015-08-21.
// Copyright © 2015 Andrew Naylor. All rights reserved.
//

import ArgumentParser
import Foundation

extension MAS {
	/// Installs previously purchased apps from the Mac App Store.
	struct Install: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Install previously purchased app(s) from the Mac App Store"
		)

		@Flag(help: "Force reinstall")
		var force = false
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
						if let appName = installedApps.first(where: { $0.id == appID })?.name, !force {
							printWarning(appName, "is already installed")
							return false
						}
						return true
					},
					verifiedBy: searcher
				)
			} catch let error as MASError {
				throw error
			} catch {
				throw MASError.downloadFailed(error: error as NSError)
			}
		}
	}
}
