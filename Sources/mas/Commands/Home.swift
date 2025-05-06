//
// Home.swift
// mas
//
// Created by Ben Chatelain on 2018-12-29.
// Copyright © 2018 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation

extension MAS {
	/// Opens app page on MAS Preview. Uses the iTunes Lookup API:
	/// https://performance-partners.apple.com/search-api
	struct Home: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Open app's Mac App Store web page in the default web browser"
		)

		@Argument(help: ArgumentHelp("App ID", valueName: "app-id"))
		var appIDs: [AppID]

		/// Runs the command.
		func run() async throws {
			try await run(searcher: ITunesSearchAppStoreSearcher())
		}

		func run(searcher: AppStoreSearcher) async throws {
			for appID in appIDs {
				let result = try await searcher.lookup(appID: appID)

				guard let url = URL(string: result.trackViewUrl) else {
					throw MASError.urlParsing(result.trackViewUrl)
				}

				try await url.open()
			}
		}
	}
}
