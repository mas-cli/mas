//
// Upgrade.swift
// mas
//
// Created by Andrew Naylor on 2015-12-30.
// Copyright © 2015 Andrew Naylor. All rights reserved.
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
		@Argument(help: ArgumentHelp("App ID/app name", valueName: "app-id-or-name"))
		var appIDOrNames = [String]()

		/// Runs the command.
		func run() async throws {
			try await run(installedApps: await installedApps, searcher: ITunesSearchAppStoreSearcher())
		}

		func run(installedApps: [InstalledApp], searcher: AppStoreSearcher) async throws {
			let apps = await findOutdatedApps(installedApps: installedApps, searcher: searcher)

			guard !apps.isEmpty else {
				return
			}

			printInfo(
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

			do {
				try await downloadApps(withAppIDs: apps.map(\.storeApp.trackId))
			} catch {
				throw MASError(downloadFailedError: error)
			}
		}

		private func findOutdatedApps(
			installedApps: [InstalledApp],
			searcher: AppStoreSearcher
		) async -> [(installedApp: InstalledApp, storeApp: SearchResult)] {
			let apps = appIDOrNames.isEmpty // swiftformat:disable:next indent
			? installedApps
			: appIDOrNames.flatMap { appIDOrName in
				if let appID = AppID(appIDOrName) {
					// Find installed apps by app ID argument
					let installedApps = installedApps.filter { $0.id == appID }
					if installedApps.isEmpty {
						printError(appID.notInstalledMessage)
					}
					return installedApps
				}

				// Find installed apps by name argument
				let installedApps = installedApps.filter { $0.name == appIDOrName }
				if installedApps.isEmpty {
					printError("Unknown app name '", appIDOrName, "'", separator: "")
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
					verboseOptionGroup.printProblem(forError: error, expectedAppName: installedApp.name)
				}
			}
			return outdatedApps
		}
	}
}
