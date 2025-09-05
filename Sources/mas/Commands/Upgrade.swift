//
// Upgrade.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Upgrades outdated apps installed from the Mac App Store.
	struct Upgrade: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Upgrade outdated apps installed from the Mac App Store"
		)

		@OptionGroup
		var verboseOptionGroup: VerboseOptionGroup
		@Argument(help: ArgumentHelp("App ID/name", valueName: "app-id-or-name"))
		var appIDOrNames = [String]()

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
			let apps = await findOutdatedApps(printer: downloader.printer, installedApps: installedApps, searcher: searcher)

			guard !apps.isEmpty else {
				return
			}

			downloader.printer.info(
				"Upgrading ",
				apps.count,
				" outdated application",
				apps.count > 1 ? "s:\n" : ":\n",
				apps.map { installedApp, storeApp in
					"\(storeApp.trackName) (\(installedApp.version)) -> (\(storeApp.version))"
				}
				.joined(separator: "\n"),
				separator: ""
			)

			for appID in apps.map(\.storeApp.trackId) {
				do {
					try await downloader.downloadApp(withAppID: appID)
				} catch {
					downloader.printer.error(error: error)
				}
			}
		}

		private func findOutdatedApps(
			printer: Printer,
			installedApps: [InstalledApp],
			searcher: AppStoreSearcher
		) async -> [(installedApp: InstalledApp, storeApp: SearchResult)] {
			let apps = appIDOrNames.isEmpty
			? installedApps // swiftformat:disable:this indent
			: appIDOrNames.flatMap { appIDOrName in
				if let appID = AppID(appIDOrName) {
					// Find installed apps by app ID argument
					let installedApps = installedApps.filter { $0.id == appID }
					if installedApps.isEmpty {
						printer.error(appID.notInstalledMessage)
					}
					return installedApps
				}

				// Find installed apps by name argument
				let installedApps = installedApps.filter { $0.name == appIDOrName }
				if installedApps.isEmpty {
					printer.error("No installed apps named", appIDOrName)
				}
				return installedApps
			}

			var outdatedApps = [(InstalledApp, SearchResult)]()
			for installedApp in apps {
				do {
					let storeApp = try await searcher.lookup(appID: installedApp.id)
					if installedApp.isOutdated(comparedTo: storeApp) {
						outdatedApps.append((installedApp, storeApp))
					}
				} catch {
					verboseOptionGroup.printProblem(forError: error, expectedAppName: installedApp.name, printer: printer)
				}
			}
			return outdatedApps
		}
	}
}
