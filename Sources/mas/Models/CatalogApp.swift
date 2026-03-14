//
// CatalogApp.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import Foundation
private import JSONAST
private import JSONDecoding
private import JSONParsing
private import Sextant
private import SwiftSoup

struct CatalogApp {
	let adamID: ADAMID
	let appStorePageURLString: String
	let minimumOSVersion: String
	let name: String
	let sellerURLString: String?
	let supportsMacDesktop: Bool
	let version: String

	private let json: String

	fileprivate var minimumOSVersionFromAppStorePage: String {
		get async {
			do {
				return try await URL(string: appStorePageURLString)
				.flatMap { url in // swiftformat:disable indent
					try unsafe SwiftSoup.parse(try await Dependencies.current.dataFrom(url).0, appStorePageURLString)
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

	fileprivate func with(minimumOSVersion: String) -> Self {
		.init(
			adamID: adamID,
			appStorePageURLString: appStorePageURLString,
			minimumOSVersion: minimumOSVersion,
			name: name,
			sellerURLString: sellerURLString,
			supportsMacDesktop: supportsMacDesktop,
			version: version,
			json: json,
		)
	}
}

extension CatalogApp: CustomStringConvertible {
	var description: String {
		json
	}
}

extension CatalogApp: JSONDecodable {
	fileprivate init(json: JSON.Node) throws {
		guard case let .object(object) = json else {
			throw MASError.unparsableJSON(String(describing: json))
		}

		adamID = try object["trackId"]?.decode() ?? 0
		appStorePageURLString = try object["trackViewUrl"]?.decode() ?? ""
		minimumOSVersion = try object["minimumOsVersion"]?.decode() ?? ""
		name = try object["trackName"]?.decode() ?? ""
		sellerURLString = try object["sellerUrl"]?.decode()
		supportsMacDesktop = try object["supportedDevices"]?.decode(to: [String]?.self)?.contains("MacDesktop-MacDesktop")
		?? false // swiftformat:disable:this indent
		version = try object["version"]?.decode() ?? ""
		self.json = String(describing: json.mappingKeys)
	}
}

private extension JSON.Node {
	var mappingKeys: Self {
		switch self {
		case let .object(object):
			.object(
				JSON.Object(
					object.fields
					.map { (JSON.Key(rawValue: $0.rawValue.keyMapped), $1.mappingKeys) } // swiftformat:disable:this indent
					.sorted(using: KeyPathComparator(\.0.rawValue, comparator: NumericStringComparator.forward)),
				), // swiftformat:disable:previous indent
			)
		case let .array(array):
			.array(JSON.Array(array.elements.map(\.mappingKeys)))
		default:
			self
		}
	}
}

private extension String {
	var keyMapped: Self {
		switch self {
		case "appletvScreenshotUrls":
			"appleTVScreenshotURLs"
		case "artistId":
			"developerID"
		case "artistName":
			"developerName"
		case "artistViewUrl":
			"developerAppStorePageURL"
		case "artworkUrl60":
			"icon60URL"
		case "artworkUrl100":
			"icon100URL"
		case "artworkUrl512":
			"icon512URL"
		case "bundleId":
			"bundleID"
		case "genreIds":
			"categoryIDs"
		case "genres":
			"categories"
		case "ipadScreenshotUrls":
			"iPadScreenshotURLs"
		case "isVppDeviceBasedLicensingEnabled":
			"isVPPDeviceBasedLicensingEnabled"
		case "minimumOsVersion":
			"minimumOSVersion"
		case "primaryGenreId":
			"primaryCategoryID"
		case "primaryGenreName":
			"primaryCategoryName"
		case "releaseDate":
			"originalVersionReleaseDate"
		case "screenshotUrls":
			"screenshotURLs"
		case "sellerUrl":
			"sellerURL"
		case "trackCensoredName":
			"censoredName"
		case "trackContentRating":
			"contentRating"
		case "trackId":
			"adamID"
		case "trackName":
			"name"
		case "trackViewUrl":
			"appStorePageURL"
		case
			"advisories",
			"averageUserRating",
			"averageUserRatingForCurrentVersion",
			"contentAdvisoryRating",
			"currency",
			"currentVersionReleaseDate",
			"description",
			"features",
			"fileSizeBytes",
			"formattedPrice",
			"isGameCenterEnabled",
			"kind",
			"languageCodesISO2A",
			"price",
			"releaseNotes",
			"sellerName",
			"supportedDevices",
			"userRatingCount",
			"userRatingCountForCurrentVersion",
			"version",
			"wrapperType"
		: // swiftformat:disable:this indent
			self
		default:
			replacing(unsafe artworkURLRegex) { match in // swiftformat:disable indent
				let output = match.output
				guard let first = output.0.first else {
					return ""
				}

				return first.isLowercase ? "icon\(output.1)URL" : "Icon\(output.1)URL"
			}
			.replacing(unsafe trackRegex) { match in
				func track(_ prefix: Self) -> Self {
					output.3.first.map { $0.isUppercase ? $0.lowercased() : "\(prefix)\(output.2)\($0)" }
					?? "\(prefix)\(output.2)"
				}

				let output = match.output
				return switch output.1 {
				case "track":
					track("app")
				case "Track":
					track("App")
				case "trackId":
					"adamID\(output.2)\(output.3)"
				case "TrackId":
					"ADAMID\(output.2)\(output.3)"
				default:
					Self(output.0)
				}
			}
			.replacing(unsafe manyRegex) { match in
				let output = match.output
				return switch output.1 {
				case "appletv":
					"appleTV\(output.2)"
				case "Appletv":
					"AppleTV\(output.2)"
				case "artist":
					"developer\(output.2)"
				case "Artist":
					"Developer\(output.2)"
				case "artwork":
					"icon\(output.2)"
				case "Artwork":
					"Icon\(output.2)"
				case "genre":
					output.2.isEmpty ? "category" : "categories"
				case "Genre":
					output.2.isEmpty ? "Category" : "Categories"
				case "Id":
					"ID\(output.2)"
				case "ipad":
					"iPad\(output.2)"
				case "Ipad":
					"IPad\(output.2)"
				case "Os":
					output.2.isEmpty ? "OS" : Self(output.0)
				case "releaseDate":
					"originalVersionReleaseDate\(output.2)"
				case "Url":
					"URL\(output.2)"
				case "view":
					"appStorePage\(output.2)"
				case "View":
					"AppStorePage\(output.2)"
				case "Vpp":
					"VPP\(output.2)"
				default:
					Self(output.0)
				}
			}
		}
	} // swiftformat:enable indent
}

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
private func lookup(appID: AppID, inRegion region: Region = appStoreRegion) async throws -> CatalogApp {
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
		.flatMap { $0.supportsMacDesktop ? $0.with(minimumOSVersion: await $0.minimumOSVersionFromAppStorePage) : nil }
		?? { throw MASError.unknownAppID(appID) }()
	} // swiftformat:enable indent
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
private func search(for searchTerm: String, inRegion region: Region = appStoreRegion) async throws -> [CatalogApp] {
	let queryItem = URLQueryItem(name: "term", value: searchTerm)
	let catalogApps = try await getCatalogApps(from: try url("search", queryItem, inRegion: region))
	let adamIDSet = Set(catalogApps.map(\.adamID))
	return catalogApps.priorityMerge(
		try await getCatalogApps(from: try url("search", queryItem, inRegion: region, additionalQueryItems: []))
		.filter { $0.supportsMacDesktop && !adamIDSet.contains($0.adamID) } // swiftformat:disable:this indent
		.concurrentMap { $0.with(minimumOSVersion: await $0.minimumOSVersionFromAppStorePage) },
	) { $0.name.similarity(to: searchTerm) } // swiftformat:disable:previous indent
}

private func url(
	_ action: String,
	_ queryItem: URLQueryItem,
	inRegion region: Region,
	additionalQueryItems: [URLQueryItem] = [URLQueryItem(name: "entity", value: "desktopSoftware")],
) throws -> URL {
	let urlString = "https://itunes.apple.com/\(action)"
	guard let url = URL(string: urlString) else {
		throw MASError.unparsableURL(urlString)
	}

	return url.appending(
		queryItems: [URLQueryItem(name: "media", value: "software")]
		+ additionalQueryItems // swiftformat:disable indent
		+ [
			URLQueryItem(name: "country", value: region),
			queryItem,
		],
	) // swiftformat:enable indent
}

private func getCatalogApps(from url: URL) async throws -> [CatalogApp] {
	let (data, _) = try await Dependencies.current.dataFrom(url)
	guard let json = String(data: data, encoding: .utf8) else {
		throw MASError.error("Failed to decode response from \(url) as UTF-8")
	}

	return try CatalogAppResults(json: JSON.Node(parsingFragment: json)).results
}

private nonisolated(unsafe) let artworkURLRegex = /(?:^artworkUrl|ArtworkUrl)(\d+)/
private nonisolated(unsafe) let trackRegex = /((?:^track|Track)(?:Id)?)(s?)($|[\d\p{Upper}])/
private nonisolated(unsafe) let manyRegex = /(^appletv|Appletv|^artist|Artist|^artwork|Artwork|^genre|Genre|Id|^ipad|Ipad|Os|^releaseDate|Url|^view|View|Vpp)(s?)(?=$|[\d\p{Upper}])/
private nonisolated(unsafe) let minimumOSVersionRegex = /macOS\s*(?<version>\S+)/
