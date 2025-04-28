//
//  Info.swift
//  mas
//
//  Created by Denis Lebedev on 21/10/2016.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import ArgumentParser

extension MAS {
	/// Displays app details. Uses the iTunes Lookup API:
	/// https://performance-partners.apple.com/search-api
	struct Info: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Display app information from the Mac App Store"
		)

		@Argument(help: "App ID")
		var appID: AppID

		/// Runs the command.
		func run() async throws {
			try await run(searcher: ITunesSearchAppStoreSearcher())
		}

		func run(searcher: AppStoreSearcher) async throws {
			do {
				print(AppInfoFormatter.format(app: try await searcher.lookup(appID: appID)))
			} catch let error as MASError {
				throw error
			} catch {
				throw MASError.searchFailed
			}
		}
	}
}
