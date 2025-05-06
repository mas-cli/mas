//
// Info.swift
// mas
//
// Created by Denis Lebedev on 2016-10-21.
// Copyright © 2016 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Displays app details. Uses the iTunes Lookup API:
	/// https://performance-partners.apple.com/search-api
	struct Info: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Display app information from the Mac App Store"
		)

		@Argument(help: ArgumentHelp("App ID", valueName: "app-id"))
		var appIDs: [AppID]

		/// Runs the command.
		func run() async throws {
			try await run(searcher: ITunesSearchAppStoreSearcher())
		}

		func run(searcher: AppStoreSearcher) async throws {
			var separator = ""
			for appID in appIDs {
				do {
					printInfo("", AppInfoFormatter.format(app: try await searcher.lookup(appID: appID)), separator: separator)
					separator = "\n"
				} catch let error as MASError {
					throw error
				} catch {
					throw MASError.searchFailed
				}
			}
		}
	}
}
