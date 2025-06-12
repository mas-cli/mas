//
// Purchase.swift
// mas
//
// Copyright © 2017 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Installs free apps that you haven’t previously acquired from the Mac App Store.
	///
	/// This command performs the equivalent of “purchasing” a free app using your Apple ID,
	/// and installs it on your Mac — similar to how you would claim a free app in the App Store GUI.
	///
	/// > Important:
	/// > This command can only be used with **free apps**.
	/// > To acquire paid apps, please purchase them directly from the App Store app.
	///
	/// > Note:
	/// > If the app is already installed or previously purchased, it will be skipped.
	///
	/// Example:
	/// ```bash
	/// mas purchase 497799835
	/// ```
	///
	/// Output:
	/// ```
	/// ==> Downloading Xcode
	/// ==> Installed Xcode
	/// ```
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
