//
//  Lucky.swift
//  mas
//
//  Created by Pablo Varela on 05/11/17.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import ArgumentParser
import Foundation

extension MAS {
	/// Command which installs the first search result.
	///
	/// This is handy as many MAS titles can be long with embedded keywords.
	struct Lucky: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract:
				"""
				Install the first app returned from searching the Mac App Store
				(app must have been previously purchased)
				"""
		)

		@Flag(help: "Force reinstall")
		var force = false
		@Argument(help: "Search term")
		var searchTerm: String

		/// Runs the command.
		func run() async throws {
			try await run(installedApps: await installedApps, searcher: ITunesSearchAppStoreSearcher())
		}

		func run(installedApps: [InstalledApp], searcher: AppStoreSearcher) async throws {
			var appID: AppID?

			do {
				let results = try await searcher.search(for: searchTerm)
				guard let result = results.first else {
					throw MASError.noSearchResultsFound
				}

				appID = result.trackId
			} catch let error as MASError {
				throw error
			} catch {
				throw MASError.searchFailed
			}

			guard let appID else {
				fatalError("app ID returned from Apple is null")
			}

			try await install(appID: appID, installedApps: installedApps)
		}

		/// Installs an app.
		///
		/// - Parameters:
		///   - appID: App identifier
		///   - installedApps: List of installed apps
		/// - Throws: Any error that occurs while attempting to install the app.
		private func install(appID: AppID, installedApps: [InstalledApp]) async throws {
			// Try to download applications with given identifiers and collect results
			if let appName = installedApps.first(where: { $0.id == appID })?.name, !force {
				printWarning(appName, "is already installed")
			} else {
				do {
					try await downloadApps(withAppIDs: [appID])
				} catch let error as MASError {
					throw error
				} catch {
					throw MASError.downloadFailed(error: error as NSError)
				}
			}
		}
	}
}
