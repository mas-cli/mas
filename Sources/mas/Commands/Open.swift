//
// Open.swift
// mas
//
// Created by Ben Chatelain on 2018-12-29.
// Copyright © 2018 mas-cli. All rights reserved.
//

private import AppKit
internal import ArgumentParser

private var masScheme: String { "macappstore" }

extension MAS {
	/// Opens app page in 'App Store.app'.
	///
	/// Uses the iTunes Lookup API:
	///
	/// https://performance-partners.apple.com/search-api
	struct Open: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Open app page in 'App Store.app'"
		)

		@Argument(help: "App ID")
		var appID: AppID?

		/// Runs the command.
		func run() async throws {
			try await run(searcher: ITunesSearchAppStoreSearcher())
		}

		func run(searcher: AppStoreSearcher) async throws {
			guard let appID else {
				// If no app ID was given, just open the MAS GUI app
				try await openMacAppStore()
				return
			}
			try await openInMacAppStore(pageForAppID: appID, searcher: searcher)
		}
	}
}

private func openMacAppStore() async throws {
	guard let macappstoreSchemeURL = URL(string: "macappstore:") else {
		throw MASError.notSupported
	}
	guard let appURL = NSWorkspace.shared.urlForApplication(toOpen: macappstoreSchemeURL) else {
		throw MASError.notSupported
	}

	try await NSWorkspace.shared.openApplication(at: appURL, configuration: NSWorkspace.OpenConfiguration())
}

private func openInMacAppStore(pageForAppID appID: AppID, searcher: AppStoreSearcher) async throws {
	let result = try await searcher.lookup(appID: appID)

	guard var urlComponents = URLComponents(string: result.trackViewUrl) else {
		throw MASError.urlParsing(result.trackViewUrl)
	}

	urlComponents.scheme = masScheme

	guard let url = urlComponents.url else {
		throw MASError.urlParsing(String(describing: urlComponents))
	}

	try await url.open()
}
