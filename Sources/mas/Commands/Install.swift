//
// Install.swift
// mas
//
// Created by Andrew Naylor on 2015-08-21.
// Copyright © 2015 Andrew Naylor. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Installs previously purchased apps from the Mac App Store.
	struct Install: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Install previously purchased apps from the Mac App Store"
		)

		@OptionGroup
		var forceOptionGroup: ForceOptionGroup
		@OptionGroup
		var appIDsOptionGroup: AppIDsOptionGroup

		/// Runs the command.
		func run() async {
			await run(installedApps: await installedApps, searcher: ITunesSearchAppStoreSearcher())
		}

		func run(installedApps: [InstalledApp], searcher: AppStoreSearcher) async {
			for appID in appIDsOptionGroup.appIDs.filter({ appID in
				if let installedApp = installedApps.first(where: { $0.id == appID }), !forceOptionGroup.force {
					printWarning("Already installed:", installedApp.idAndName)
					return false
				}
				return true
			}) {
				do {
					_ = try await searcher.lookup(appID: appID)
					try await downloadApp(withAppID: appID)
				} catch {
					printError(error)
				}
			}
		}
	}
}
