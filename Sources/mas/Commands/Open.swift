//
// Open.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import AppKit
internal import ArgumentParser
private import Foundation
private import ObjectiveC

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

		@OptionGroup
		var forceBundleIDOptionGroup: ForceBundleIDOptionGroup
		@Argument(help: ArgumentHelp("App ID", valueName: "app-id"))
		var appIDString: String?

		func run() async throws {
			try await run(searcher: ITunesSearchAppStoreSearcher())
		}

		func run(searcher: AppStoreSearcher) async throws {
			try await MAS.run { try await run(printer: $0, searcher: searcher) }
		}

		private func run(printer _: Printer, searcher: AppStoreSearcher) async throws {
			guard let appIDString else {
				// If no app ID was given, just open the MAS GUI app
				try await openMacAppStore()
				return
			}

			try await openMacAppStorePage(
				forURLString: try await searcher.lookup(
					appID: AppID(from: appIDString, forceBundleID: forceBundleIDOptionGroup.forceBundleID)
				)
				.appStoreURL
			)
		}
	}
}

private func openMacAppStore() async throws {
	guard let macappstoreSchemeURL = URL(string: "macappstore:") else {
		throw MASError.runtimeError("Failed to create URL from macappstore scheme")
	}
	guard let appURL = NSWorkspace.shared.urlForApplication(toOpen: macappstoreSchemeURL) else {
		throw MASError.runtimeError("Failed to find app to open macappstore URLs")
	}

	try await NSWorkspace.shared.openApplication(at: appURL, configuration: NSWorkspace.OpenConfiguration())
}

private func openMacAppStorePage(forURLString urlString: String) async throws {
	guard var urlComponents = URLComponents(string: urlString) else {
		throw MASError.urlParsing(urlString)
	}

	urlComponents.scheme = masScheme
	guard let url = urlComponents.url else {
		throw MASError.urlParsing(String(describing: urlComponents))
	}

	try await url.open()
}
