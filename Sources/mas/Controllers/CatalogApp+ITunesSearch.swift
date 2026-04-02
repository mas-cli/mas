//
// CatalogApp+ITunesSearch.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

internal import Foundation
private import Sextant
private import SwiftSoup

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
func lookup(appID: AppID, inRegion region: Region = appStoreRegion) async throws -> CatalogApp {
	let queryItem = switch appID {
	case let .adamID(adamID):
		URLQueryItem(name: "id", value: .init(adamID))
	case let .bundleID(bundleID):
		URLQueryItem(name: "bundleId", value: bundleID)
	}
	return if // swiftformat:disable:this wrap wrapArguments
		let catalogApp = // swiftformat:disable:next indent
			try await getCatalogApps(from: try url("lookup", queryItem, inRegion: region)).first
	{
		catalogApp
	} else {
		try await getCatalogApps(from: try url("lookup", queryItem, inRegion: region, additionalQueryItems: []))
		.first // swiftformat:disable indent
		.flatMap { catalogApp in
			catalogApp.supportedDevices?.contains("MacDesktop-MacDesktop") == true
			? catalogApp.with(minimumOSVersion: await catalogApp.minimumOSVersionFromAppStorePage)
			: nil
		}
		?? { throw MASError.unknownAppID(appID) }()
	} // swiftformat:enable indent
}

private extension CatalogApp {
	var minimumOSVersionFromAppStorePage: String {
		get async {
			do {
				return try await URL(string: appStorePageURLString)
				.flatMap { url in // swiftformat:disable indent
					try SwiftSoup.parse(try await Dependencies.current.dataFrom(url).0, appStorePageURLString)
					.select("#serialized-server-data")
					.first()?
					.data()
					.query(
						string:
							"$.data[0].data.shelfMapping.information.items[?(@.title == 'Compatibility')].items[?(@.heading == 'Mac')].text",
					)?
					.firstMatch(of: minimumOSVersionRegex)?
					.version
				}
				.map(String.init(_:)) ?? minimumOSVersion // swiftformat:enable indent
			} catch {
				return minimumOSVersion
			}
		}
	}
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
func search(for searchTerm: String, inRegion region: Region = appStoreRegion) async throws -> [CatalogApp] {
	let queryItem = URLQueryItem(name: "term", value: searchTerm)
	let catalogApps = try await getCatalogApps(from: try url("search", queryItem, inRegion: region))
	let adamIDSet = Set(catalogApps.map(\.adamID))
	return catalogApps.priorityMerge( // swiftformat:disable indent
		try await getCatalogApps(from: try url("search", queryItem, inRegion: region, additionalQueryItems: []))
		.filter { ($0.supportedDevices?.contains("MacDesktop-MacDesktop") == true) && !adamIDSet.contains($0.adamID) }
		.concurrentMap { $0.with(minimumOSVersion: await $0.minimumOSVersionFromAppStorePage) },
	) { $0.name.similarity(to: searchTerm) } // swiftformat:enable indent
}

private func url(
	_ action: String,
	_ queryItem: URLQueryItem,
	inRegion region: Region,
	additionalQueryItems: [URLQueryItem] = [.init(name: "entity", value: "desktopSoftware")],
) throws -> URL {
	let urlString = "https://itunes.apple.com/\(action)"
	guard let url = URL(string: urlString) else {
		throw MASError.unparsableURL(urlString)
	}

	return url.appending(
		queryItems: [.init(name: "media", value: "software")]
		+ additionalQueryItems // swiftformat:disable:this indent
		+ [.init(name: "country", value: region), queryItem], // swiftformat:disable:this indent
	)
}

private func getCatalogApps(from url: URL) async throws -> [CatalogApp] {
	let (data, _) = try await Dependencies.current.dataFrom(url)
	do {
		return try JSONDecoder().decode(CatalogAppResults.self, from: data).results
	} catch {
		throw MASError.error("Failed to parse JSON from response \(url)", error: .init(data: data, encoding: .utf8) ?? "")
	}
}

private let minimumOSVersionRegex = /macOS\s*(?<version>\S+)/
