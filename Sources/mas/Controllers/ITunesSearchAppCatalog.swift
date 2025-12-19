//
// ITunesSearchAppCatalog.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

internal import Foundation

/// Uses the iTunes Search & Lookup APIs to search for, and to look up, apps
/// from the MAS catalog.
///
/// Uses the iTunes Search & Lookup APIs:
///
/// https://performance-partners.apple.com/search-api
struct ITunesSearchAppCatalog: AppCatalog {
	private let dataFrom: @Sendable (URL) async throws -> (Data, URLResponse)

	init(
		dataFrom: @Sendable @escaping (URL) async throws -> (Data, URLResponse)
		= URLSession(configuration: .ephemeral).data(from:) // swiftformat:disable:this indent
	) {
		self.dataFrom = dataFrom
	}

	/// Looks up app details.
	///
	/// - Parameters:
	///   - appID: App ID.
	///   - region: The ISO 3166-1 alpha-2 region of the storefront in which to
	///     lookup apps.
	/// - Returns: A `CatalogApp` for the given `appID` if `appID` is valid.
	/// - Throws: A `MASError.unknownAppID(appID)` if `appID` is invalid.
	///   Some other `Error` if any other problem occurs.
	func lookup(appID: AppID, inRegion region: Region) async throws -> CatalogApp {
		guard
			let catalogApp = try await getCatalogApps(from: try lookupURL(forAppID: appID, inRegion: region)).first
		else {
			throw MASError.unknownAppID(appID)
		}

		return catalogApp
	}

	/// Searches for apps.
	///
	/// - Parameters:
	///   - searchTerm: Term for which to search.
	///   - region: The ISO 3166-1 alpha-2 region of the storefront in which to
	///     search for apps.
	/// - Returns: A `[CatalogApp]` matching `searchTerm`.
	/// - Throws: An `Error` if any problem occurs.
	func search(for searchTerm: String, inRegion region: Region) async throws -> [CatalogApp] {
		try await getCatalogApps(from: try searchURL(for: searchTerm, inRegion: region))
	}

	/// Builds the lookup URL for an app.
	///
	/// - Parameters:
	///   - appID: App ID.
	///   - region: The ISO 3166-1 alpha-2 region of the storefront in which to
	///     lookup apps.
	/// - Returns: URL for the lookup service.
	/// - Throws: An `MASError.unparsableURL` if `appID` can't be encoded.
	private func lookupURL(forAppID appID: AppID, inRegion region: Region) throws -> URL {
		let queryItem =
			switch appID {
			case let .adamID(adamID):
				URLQueryItem(name: "id", value: String(adamID))
			case let .bundleID(bundleID):
				URLQueryItem(name: "bundleId", value: bundleID)
			}
		return try url("lookup", queryItem, inRegion: region)
	}

	/// Builds the search URL for an app.
	///
	/// - Parameters:
	///   - searchTerm: term for which to search in MAS.
	///   - region: The ISO 3166-1 alpha-2 region of the storefront in which to
	///     search for apps.
	/// - Returns: URL for the search service.
	/// - Throws: An `MASError.unparsableURL` if `searchTerm` can't be encoded.
	private func searchURL(for searchTerm: String, inRegion region: Region) throws -> URL {
		try url("search", URLQueryItem(name: "term", value: searchTerm), inRegion: region)
	}

	private func url(_ action: String, _ queryItem: URLQueryItem, inRegion region: Region) throws -> URL {
		let urlString = "https://itunes.apple.com/\(action)"
		guard var urlComponents = URLComponents(string: urlString) else {
			throw MASError.unparsableURL(urlString)
		}

		let queryItems = [
			URLQueryItem(name: "media", value: "software"),
			URLQueryItem(name: "entity", value: "desktopSoftware"),
			URLQueryItem(name: "country", value: region),
			queryItem,
		]

		urlComponents.queryItems = queryItems

		guard let url = urlComponents.url else {
			throw MASError.unparsableURL("\(urlString)?\(queryItems.map(String.init(describing:)).joined(separator: "&"))")
		}

		return url
	}

	private func getCatalogApps(from url: URL) async throws -> [CatalogApp] {
		let (data, _) = try await dataFrom(url)
		do {
			return try JSONDecoder().decode(CatalogAppResults.self, from: data).results
		} catch {
			throw MASError.error(
				"Failed to parse response from \(url) as JSON",
				error: String(data: data, encoding: .utf8) ?? ""
			)
		}
	}
}
