//
// Purchase.swift
// mas
//
// Copyright © 2017 mas-cli. All rights reserved.
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
			try await mas.run { printer in
				await run(downloader: Downloader(printer: printer), installedApps: installedApps, searcher: searcher)
			}
		}

		private func run(downloader: Downloader, installedApps: [InstalledApp], searcher: AppStoreSearcher) async {
			for appID in appIDsOptionGroup.appIDs.filter({ appID in
				if let installedApp = installedApps.first(where: { $0.id == appID }) {
					downloader.printer.warning("Already purchased:", installedApp.idAndName)
					return false
				}
				return true
			}) {
				do {
					_ = try await searcher.lookup(appID: appID)
					try await downloader.downloadApp(withAppID: appID, purchasing: true)
				} catch {
					downloader.printer.error(error: error)
				}
			}
		}
	}
}
