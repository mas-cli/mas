//
// ITunesSearchAppCatalog.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

internal import Foundation

func lookup(appID: AppID) async throws -> CatalogApp {
	try await lookup(appID: appID, inRegion: appStoreRegion)
}

/// Look up app details from the App Store catalog via the iTunes Search API.
///
/// https://performance-partners.apple.com/search-api
///
/// - Parameters:
///   - appID: App ID.
///   - region: The ISO 3166-1 alpha-2 region of the storefront in which to
///     lookup apps.
/// - Returns: A `CatalogApp` for the given `appID` if `appID` is valid.
/// - Throws: A `MASError.unknownAppID(appID)` if `appID` is invalid.
///   Some other `Error` if any other problem occurs.
func lookup(
	appID: AppID,
	inRegion region: Region = appStoreRegion,
	dataFrom dataSource: (URL) async throws -> (Data, URLResponse) = urlSession.data(from:)
) async throws -> CatalogApp {
	let queryItem =
		switch appID {
		case let .adamID(adamID):
			URLQueryItem(name: "id", value: String(adamID))
		case let .bundleID(bundleID):
			URLQueryItem(name: "bundleId", value: bundleID)
		}
	guard
		let catalogApp = // swiftformat:disable:next indent
			try await getCatalogApps(from: try url("lookup", queryItem, inRegion: region), dataFrom: dataSource).first
	else {
		throw MASError.unknownAppID(appID)
	}

	return catalogApp
}

func search(for searchTerm: String) async throws -> [CatalogApp] {
	try await search(for: searchTerm, inRegion: appStoreRegion)
}

/// Search for app details from the App Store catalog via the iTunes Search API.
///
/// https://performance-partners.apple.com/search-api
///
/// - Parameters:
///   - searchTerm: Term for which to search.
///   - region: The ISO 3166-1 alpha-2 region of the storefront in which to
///     search for apps.
/// - Returns: A `[CatalogApp]` matching `searchTerm`.
/// - Throws: An `Error` if any problem occurs.
func search(
	for searchTerm: String,
	inRegion region: Region = appStoreRegion,
	dataFrom dataSource: (URL) async throws -> (Data, URLResponse) = urlSession.data(from:)
) async throws -> [CatalogApp] {
	try await getCatalogApps(
		from: try url("search", URLQueryItem(name: "term", value: searchTerm), inRegion: region),
		dataFrom: dataSource
	)
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

private func getCatalogApps(
	from url: URL,
	dataFrom: (URL) async throws -> (Data, URLResponse)
) async throws -> [CatalogApp] {
	let (data, _) = try await dataFrom(url)
	do {
		return try JSONDecoder().decode(CatalogAppResults.self, from: data).results
	} catch {
		throw MASError.error("Failed to parse JSON from response \(url)", error: String(data: data, encoding: .utf8) ?? "")
	}
}

private let urlSession = URLSession(configuration: .ephemeral)
