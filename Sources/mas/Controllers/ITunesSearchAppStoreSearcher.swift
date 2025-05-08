//
// ITunesSearchAppStoreSearcher.swift
// mas
//
// Created by Ben Chatelain on 2018-12-29.
// Copyright © 2018 mas-cli. All rights reserved.
//

private import Foundation

/// Manages searching the MAS catalog. Uses the iTunes Search and Lookup APIs:
/// https://performance-partners.apple.com/search-api
struct ITunesSearchAppStoreSearcher: AppStoreSearcher {
	enum Entity: String {
		case desktopSoftware
		case macSoftware
		case iPadSoftware
		case iPhoneSoftware = "software"
	}

	private let networkSession: NetworkSession

	/// Designated initializer.
	init(networkSession: NetworkSession = URLSession(configuration: .ephemeral)) {
		self.networkSession = networkSession
	}

	/// Looks up app details.
	///
	/// - Parameters:
	///   - appID: App ID.
	///   - region: The `ISORegion` of the storefront in which to lookup apps.
	/// - Returns: A `SearchResult` for the given `appID` if `appID` is valid.
	/// - Throws: A `MASError.unknownAppID(appID)` if `appID` is invalid.
	///   Some other `Error` if any other problem occurs.
	func lookup(appID: AppID, inRegion region: ISORegion?) async throws -> SearchResult {
		guard let url = lookupURL(forAppID: appID, inRegion: region) else {
			fatalError("Failed to build URL for \(appID)")
		}
		let results = try await getSearchResults(from: url)
		guard let result = results.first else {
			throw MASError.unknownAppID(appID)
		}
		return result
	}

	/// Searches for apps.
	///
	/// - Parameters:
	///   - searchTerm: Term for which to search.
	///   - region: The `ISORegion` of the storefront in which to search for apps.
	/// - Returns: An `Array` of `SearchResult`s matching `searchTerm`.
	/// - Throws: An `Error` if any problem occurs.
	func search(for searchTerm: String, inRegion region: ISORegion?) async throws -> [SearchResult] {
		// Search for apps for compatible platforms, in order of preference.
		// Macs with Apple Silicon can run iPad and iPhone apps.
		#if arch(arm64)
		let entities = [Entity.desktopSoftware, .iPadSoftware, .iPhoneSoftware]
		#else
		let entities = [Entity.desktopSoftware]
		#endif

		var appSet = Set<SearchResult>()
		for entity in entities {
			guard let url = searchURL(for: searchTerm, inRegion: region, ofEntity: entity) else {
				fatalError("Failed to build URL for \(searchTerm)")
			}
			appSet.formUnion(try await getSearchResults(from: url))
		}

		return Array(appSet)
	}

	/// Builds the lookup URL for an app.
	///
	/// - Parameters:
	///   - appID: App ID.
	///   - region: The `ISORegion` of the storefront in which to lookup apps.
	///   - entity: OS platform of apps for which to search.
	/// - Returns: URL for the lookup service or nil if appID can't be encoded.
	private func lookupURL(
		forAppID appID: AppID,
		inRegion region: ISORegion?,
		ofEntity entity: Entity = .desktopSoftware
	) -> URL? {
		url("lookup", URLQueryItem(name: "id", value: String(appID)), inRegion: region, ofEntity: entity)
	}

	/// Builds the search URL for an app.
	///
	/// - Parameters:
	///   - searchTerm: term for which to search in MAS.
	///   - region: The `ISORegion` of the storefront in which to lookup apps.
	///   - entity: OS platform of apps for which to search.
	/// - Returns: URL for the search service or nil if searchTerm can't be encoded.
	private func searchURL(
		for searchTerm: String,
		inRegion region: ISORegion?,
		ofEntity entity: Entity = .desktopSoftware
	) -> URL? {
		url("search", URLQueryItem(name: "term", value: searchTerm), inRegion: region, ofEntity: entity)
	}

	private func url(
		_ action: String,
		_ queryItem: URLQueryItem,
		inRegion region: ISORegion?,
		ofEntity entity: Entity = .desktopSoftware
	) -> URL? {
		guard var components = URLComponents(string: "https://itunes.apple.com/\(action)") else {
			return nil
		}

		var queryItems = [
			URLQueryItem(name: "media", value: "software"),
			URLQueryItem(name: "entity", value: entity.rawValue),
		]

		if let region {
			queryItems.append(URLQueryItem(name: "country", value: region.alpha2))
		}

		queryItems.append(queryItem)

		components.queryItems = queryItems

		return components.url
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
