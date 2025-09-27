//
// ITunesSearchAppStoreSearcher.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import Foundation

/// Manages searching the MAS catalog.
///
/// Uses the iTunes Search & Lookup APIs:
///
/// https://performance-partners.apple.com/search-api
struct ITunesSearchAppStoreSearcher: AppStoreSearcher {
	private let networkSession: NetworkSession

	/// Designated initializer.
	init(networkSession: NetworkSession = URLSession(configuration: .ephemeral)) {
		self.networkSession = networkSession
	}

	/// Looks up app details.
	///
	/// - Parameters:
	///   - appID: App ID.
	///   - region: The ISO 3166-1 region alpha-2 of the storefront in which to
	///     lookup apps.
	/// - Returns: A `SearchResult` for the given `appID` if `appID` is valid.
	/// - Throws: A `MASError.unknownAppID(appID)` if `appID` is invalid.
	///   Some other `Error` if any other problem occurs.
	func lookup(appID: AppID, inRegion region: String) async throws -> SearchResult {
		guard let result = try await getSearchResults(from: try lookupURL(forAppID: appID, inRegion: region)).first else {
			throw MASError.unknownAppID(appID)
		}

		return result
	}

	/// Searches for apps.
	///
	/// - Parameters:
	///   - searchTerm: Term for which to search.
	///   - region: The ISO 3166-1 region alpha-2 of the storefront in which to
	///     search for apps.
	/// - Returns: An `Array` of `SearchResult`s matching `searchTerm`.
	/// - Throws: An `Error` if any problem occurs.
	func search(for searchTerm: String, inRegion region: String) async throws -> [SearchResult] {
		try await getSearchResults(from: try searchURL(for: searchTerm, inRegion: region))
	}

	/// Builds the lookup URL for an app.
	///
	/// - Parameters:
	///   - appID: App ID.
	///   - region: The ISO 3166-1 region alpha-2 of the storefront in which to
	///     lookup apps.
	/// - Returns: URL for the lookup service.
	/// - Throws: An `MASError.urlParsing` if `appID` can't be encoded.
	private func lookupURL(forAppID appID: AppID, inRegion region: String) throws -> URL {
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
	///   - region: The ISO 3166-1 region alpha-2 of the storefront in which to
	///     search for apps.
	/// - Returns: URL for the search service.
	/// - Throws: An `MASError.urlParsing` if `searchTerm` can't be encoded.
	private func searchURL(for searchTerm: String, inRegion region: String) throws -> URL {
		try url("search", URLQueryItem(name: "term", value: searchTerm), inRegion: region)
	}

	private func url(_ action: String, _ queryItem: URLQueryItem, inRegion region: String) throws -> URL {
		let urlBase = "https://itunes.apple.com/\(action)"
		guard var urlComponents = URLComponents(string: urlBase) else {
			throw MASError.urlParsing(urlBase)
		}

		let queryItems = [
			URLQueryItem(name: "media", value: "software"),
			URLQueryItem(name: "entity", value: "desktopSoftware"),
			URLQueryItem(name: "country", value: region),
			queryItem,
		]

		urlComponents.queryItems = queryItems

		guard let url = urlComponents.url else {
			throw MASError.urlParsing("\(urlBase)?\(queryItems.map(\.description).joined(separator: "&"))")
		}

		return url
	}

	private func getSearchResults(from url: URL) async throws -> [SearchResult] {
		let (data, _) = try await networkSession.data(from: url)
		do {
			return try JSONDecoder().decode(SearchResultList.self, from: data).results
		} catch {
			throw MASError.jsonParsing(data: data)
		}
	}
}
