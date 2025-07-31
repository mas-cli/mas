//
// Open.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import AppKit
internal import ArgumentParser

private var masScheme: String { "macappstore" }

extension MAS {
	/// Opens the specified app’s page in the macOS App Store (`App Store.app`).
	///
	/// This command launches the App Store app using the `macappstore:` URL scheme,
	/// targeting the app corresponding to the provided App ID.
	/// If no App ID is specified, the App Store app is simply opened.
	///
	/// This is useful when you want to view an app’s description, screenshots, reviews,
	/// or permissions before deciding to install or update.
	///
	/// Example (with App ID):
	/// ```bash
	/// mas open 497799835
	/// ```
	///
	/// Example (without App ID):
	/// ```bash
	/// mas open
	/// ```
	///
	/// > Tip:
	/// > Use this command when you want to review an app visually before installation.
	///
	/// See also:
	/// [iTunes Search API](https://performance-partners.apple.com/search-api)
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
			try await mas.run { try await run(printer: $0, searcher: searcher) }
		}

		private func run(printer _: Printer, searcher: AppStoreSearcher) async throws {
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
		throw MASError.runtimeError("Failed to create URL from macappstore scheme")
	}
	guard let appURL = NSWorkspace.shared.urlForApplication(toOpen: macappstoreSchemeURL) else {
		throw MASError.runtimeError("Failed to find app to open macappstore URLs")
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
