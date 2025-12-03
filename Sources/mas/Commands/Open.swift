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

extension MAS {
	/// Opens app page in 'App Store.app'.
	///
	/// Uses the iTunes Lookup API:
	///
	/// https://performance-partners.apple.com/search-api
	struct Open: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "Open app page in 'App Store.app'"
		)

		@OptionGroup
		private var forceBundleIDOptionGroup: ForceBundleIDOptionGroup
		@Argument(help: ArgumentHelp("App ID", valueName: "app-id"))
		private var appIDString: String?

		func run() async {
			do {
				try await run(appCatalog: ITunesSearchAppCatalog())
			} catch {
				printer.error(error: error)
			}
		}

		private func run(appCatalog: some AppCatalog) async throws {
			try await run(appStorePageURLString: appStorePageURLString(appCatalog: appCatalog))
		}

		private func run(appStorePageURLString: String?) async throws {
			guard let appStorePageURLString else {
				// If no App Store Page URL was given, just open the MAS GUI app
				try await openMacAppStore()
				return
			}

			try await openMacAppStorePage(forAppStorePageURLString: appStorePageURLString)
		}

		private func appStorePageURLString(appCatalog: some AppCatalog) async throws -> String? {
			guard let appIDString else {
				return nil
			}

			return try await appCatalog.lookup(
				appID: AppID(from: appIDString, forceBundleID: forceBundleIDOptionGroup.forceBundleID)
			)
			.appStorePageURLString
		}
	}
}

private func openMacAppStore() async throws {
	guard let macAppStoreSchemeURL = URL(string: "macappstore:") else {
		throw MASError.error("Failed to create URL from macappstore scheme")
	}

	let workspace = NSWorkspace.shared
	guard let appURL = workspace.urlForApplication(toOpen: macAppStoreSchemeURL) else {
		throw MASError.error("Failed to find app to open macappstore URLs")
	}

	try await workspace.openApplication(at: appURL, configuration: NSWorkspace.OpenConfiguration())
}

private func openMacAppStorePage(forAppStorePageURLString appStorePageURLString: String) async throws {
	guard var urlComponents = URLComponents(string: appStorePageURLString) else {
		throw MASError.unparsableURL(appStorePageURLString)
	}

	urlComponents.scheme = masScheme
	guard let url = urlComponents.url else {
		throw MASError.unparsableURL(String(describing: urlComponents))
	}

	try await url.open()
}

private let masScheme = "macappstore"
